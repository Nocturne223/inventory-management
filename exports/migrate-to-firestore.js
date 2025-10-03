// migrate-to-firestore.js
// Minimal migration helper to import JSON exports into Firestore using the Admin SDK.
// Usage (PowerShell):
// $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\serviceAccount.json"; node tools/migrate-to-firestore.js

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// CLI args
const argv = process.argv.slice(2);
const dryRun = argv.includes('--dry-run');
const collectionsArg = argv.find(a => a.startsWith('--collections='));
const collectionsFilter = collectionsArg ? collectionsArg.split('=')[1].split(',').map(s => s.trim()) : null;
const serviceAccountArg = argv.find(a => a.startsWith('--service-account='));
const serviceAccountPath = serviceAccountArg ? serviceAccountArg.split('=')[1] : null;
const projectArg = argv.find(a => a.startsWith('--project='));
const targetProjectId = projectArg ? projectArg.split('=')[1] : null;
const minArg = argv.find(a => a.startsWith('--min-per-collection='));
const minPerCollection = minArg ? parseInt(minArg.split('=')[1], 10) : 0;

function shouldProcess(name) {
  if (!collectionsFilter) return true;
  return collectionsFilter.includes(name);
}

function dryRunReport(collectionPath, docs) {
  console.log(`DRY-RUN: collection='${collectionPath}' count=${docs.length}`);
  if (docs.length > 0) {
    const sample = docs.slice(0, 2);
    console.log(' sample doc(s):', JSON.stringify(sample, null, 2));
  }
}

function ensureMinDocs(docs, collectionPath) {
  if (!minPerCollection || docs.length >= minPerCollection) return docs;
  const out = docs.slice();
  if (out.length === 0) {
    // generate placeholder docs
    for (let i = 1; i <= minPerCollection; i++) {
      out.push({ id: `sample-${i}`, _generated: true, createdAt: admin.firestore.FieldValue.serverTimestamp() });
    }
    return out;
  }
  // duplicate existing docs to reach min
  let dupIndex = 1;
  while (out.length < minPerCollection) {
    const src = docs[(dupIndex - 1) % docs.length];
    const copy = JSON.parse(JSON.stringify(src));
    // create a new doc id
    const baseId = copy.id ? String(copy.id) : `doc`;
    copy.id = `${baseId}-dup-${dupIndex}`;
    // mark generated
    copy._generated = true;
    // ensure createdAt is a server timestamp
    copy.createdAt = admin.firestore.FieldValue.serverTimestamp();
    out.push(copy);
    dupIndex++;
  }
  return out;
}

// Initialize Admin SDK: prefer explicit service account if provided, otherwise use Application Default
if (serviceAccountPath) {
  try {
    const sa = require(serviceAccountPath);
    const initOptions = { credential: admin.credential.cert(sa) };
    if (targetProjectId) initOptions.projectId = targetProjectId;
    admin.initializeApp(initOptions);
    console.log('Initialized firebase-admin with service account:', serviceAccountPath);
    if (targetProjectId) console.log('Target projectId:', targetProjectId);
  } catch (err) {
    console.error('Failed to initialize service account from', serviceAccountPath, err.message);
    process.exit(1);
  }
} else {
  // If not using explicit service account, fall back to Application Default Credentials
  try {
    admin.initializeApp();
    console.log('Initialized firebase-admin using Application Default Credentials.');
  } catch (err) {
    console.error('Failed to initialize firebase-admin with Application Default Credentials:', err.message);
    process.exit(1);
  }
}

const db = admin.firestore();

async function writeBatch(collectionPath, docs) {
  const batchLimit = 500;
  if (dryRun) {
    dryRunReport(collectionPath, docs);
    return;
  }
  for (let i = 0; i < docs.length; i += batchLimit) {
    const batch = db.batch();
    const slice = docs.slice(i, i + batchLimit);
    for (const doc of slice) {
      const ref = doc.id ? db.collection(collectionPath).doc(String(doc.id)) : db.collection(collectionPath).doc();
      batch.set(ref, doc, { merge: true });
    }
    await batch.commit();
    console.log(`Wrote ${Math.min(i + batchLimit, docs.length)} / ${docs.length} to ${collectionPath}`);
  }
}

async function migrate() {
  const base = path.join(__dirname, '..', 'exports');
  if (!fs.existsSync(base)) {
    console.error('exports/ directory not found. Create exports/*.json files per table.');
    process.exit(1);
  }

  const readJson = (name) => {
    const p = path.join(base, name + '.json');
    if (!fs.existsSync(p)) return [];
    return JSON.parse(fs.readFileSync(p, 'utf8'));
  };

  const departments = readJson('departments');
  const locations = readJson('locations');
  const items = readJson('items');
  const systemUnits = readJson('system_units');
  const components = readJson('system_unit_components');
  const deployments = readJson('deployments');
  const deploymentItems = readJson('deployment_items');

  if (departments.length && shouldProcess('departments')) {
    const docs = departments.map(d => ({
      id: String(d.id),
      code: d.code,
      name: d.name,
      description: d.description || null,
      contact_person: d.contact_person || null,
      contact_email: d.contact_email || null,
      contact_phone: d.contact_phone || null,
      createdAt: d.created_at ? admin.firestore.Timestamp.fromDate(new Date(d.created_at)) : admin.firestore.FieldValue.serverTimestamp()
    }));
    await writeBatch('departments', docs);
  }

  if (locations.length && shouldProcess('locations')) {
    const docs = locations.map(l => ({
      id: String(l.id),
      name: l.name,
      address: l.address || null,
      contact_person: l.contact_person || null,
      phone: l.phone || null,
      departmentId: l.department_id ? String(l.department_id) : null,
      roomIdentifier: l.room_identifier || null,
      createdAt: l.created_at ? admin.firestore.Timestamp.fromDate(new Date(l.created_at)) : admin.firestore.FieldValue.serverTimestamp()
    }));
    await writeBatch('locations', docs);
  }

  if (items.length && shouldProcess('items')) {
    const docs = items.map(i => ({
      id: String(i.id),
      sku: i.sku,
      name: i.name,
      description: i.description || null,
      categoryId: i.category_id ? String(i.category_id) : null,
      supplierId: i.supplier_id ? String(i.supplier_id) : null,
      modelNumber: i.model_number || null,
      specifications: i.specifications || null,
      warrantyPeriod: i.warranty_period || null,
      minimumStock: i.minimum_stock || 0,
      isSerialized: Boolean(i.is_serialized),
      lifecycleStage: i.lifecycle_stage || 'active',
      replacementCost: i.replacement_cost ? Number(i.replacement_cost) : null,
      averageLifespan: i.average_lifespan || null,
      status: i.status || 'active',
      assetTagPrefix: i.asset_tag_prefix || null,
      requiresAssetTag: Boolean(i.requires_asset_tag),
      createdAt: i.created_at ? admin.firestore.Timestamp.fromDate(new Date(i.created_at)) : admin.firestore.FieldValue.serverTimestamp()
    }));
    await writeBatch('items', docs);
  }

  // system units and components
  if (systemUnits.length && shouldProcess('system_units')) {
    if (dryRun) {
      const docs = systemUnits.map(su => ({
        id: String(su.id),
        unitIdentifier: su.unit_identifier,
        name: su.name,
        systemType: su.system_type,
        configurationNotes: su.configuration_notes || null,
        deploymentId: su.deployment_id ? String(su.deployment_id) : null,
        status: su.status || 'available',
        createdAt: su.created_at ? su.created_at : null
      }));
      dryRunReport('system_units', docs);
    } else {
      for (const su of systemUnits) {
        const suRef = db.collection('system_units').doc(String(su.id));
        await suRef.set({
          id: String(su.id),
          unitIdentifier: su.unit_identifier,
          name: su.name,
          systemType: su.system_type,
          configurationNotes: su.configuration_notes || null,
          deploymentId: su.deployment_id ? String(su.deployment_id) : null,
          status: su.status || 'available',
          createdAt: su.created_at ? admin.firestore.Timestamp.fromDate(new Date(su.created_at)) : admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }
  }

  if (components.length && shouldProcess('system_unit_components')) {
    if (dryRun) {
      const docs = components.map(c => ({
        id: String(c.id),
        system_unit_id: String(c.system_unit_id),
        itemId: c.item_id ? String(c.item_id) : null,
        assetTag: c.asset_tag || null,
        isPrimary: Boolean(c.is_primary),
        installedDate: c.installed_date || null,
        removedDate: c.removed_date || null,
        notes: c.notes || null,
        createdAt: c.created_at || null
      }));
      dryRunReport('system_units/{unitId}/components', docs);
    } else {
      for (const c of components) {
        const compRef = db.collection('system_units').doc(String(c.system_unit_id)).collection('components').doc(String(c.id));
        await compRef.set({
          id: String(c.id),
          itemId: c.item_id ? String(c.item_id) : null,
          assetTag: c.asset_tag || null,
          isPrimary: Boolean(c.is_primary),
          installedDate: c.installed_date ? admin.firestore.Timestamp.fromDate(new Date(c.installed_date)) : null,
          removedDate: c.removed_date ? admin.firestore.Timestamp.fromDate(new Date(c.removed_date)) : null,
          notes: c.notes || null,
          createdAt: c.created_at ? admin.firestore.Timestamp.fromDate(new Date(c.created_at)) : admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }
  }

  if (deployments.length && shouldProcess('deployments')) {
    if (dryRun) {
      const docs = deployments.map(d => ({
        id: String(d.id),
        requestNumber: d.request_number || null,
        requesterId: d.requester_id ? String(d.requester_id) : null,
        departmentId: d.department_id ? String(d.department_id) : null,
        status: d.status || 'requested',
        issuedDate: d.issued_date || null,
        createdAt: d.created_at || null
      }));
      dryRunReport('deployments', docs);
    } else {
      for (const d of deployments) {
        const dRef = db.collection('deployments').doc(String(d.id));
        await dRef.set({
          id: String(d.id),
          requestNumber: d.request_number || null,
          requesterId: d.requester_id ? String(d.requester_id) : null,
          approvedBy: d.approved_by ? String(d.approved_by) : null,
          issuedBy: d.issued_by ? String(d.issued_by) : null,
          pickupLocationId: d.pickup_location_id ? String(d.pickup_location_id) : null,
          departmentId: d.department_id ? String(d.department_id) : null,
          roomIdentifier: d.room_identifier || null,
          receiverName: d.receiver_name || null,
          deploymentType: d.deployment_type || 'individual_item',
          totalItemsCount: d.total_items_count || 0,
          purpose: d.purpose || null,
          status: d.status || 'requested',
          requestedDate: d.requested_date ? admin.firestore.Timestamp.fromDate(new Date(d.requested_date)) : null,
          approvedDate: d.approved_date ? admin.firestore.Timestamp.fromDate(new Date(d.approved_date)) : null,
          issuedDate: d.issued_date ? admin.firestore.Timestamp.fromDate(new Date(d.issued_date)) : null,
          expectedReturnDate: d.expected_return_date ? admin.firestore.Timestamp.fromDate(new Date(d.expected_return_date)) : null,
          completedDate: d.completed_date ? admin.firestore.Timestamp.fromDate(new Date(d.completed_date)) : null,
          notes: d.notes || null,
          createdAt: d.created_at ? admin.firestore.Timestamp.fromDate(new Date(d.created_at)) : admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }
  }

  if (deploymentItems.length && shouldProcess('deployment_items')) {
    if (dryRun) {
      const docs = deploymentItems.map(li => ({
        id: String(li.id),
        deployment_id: String(li.deployment_id),
        itemId: li.item_id ? String(li.item_id) : null,
        quantityRequested: li.quantity_requested || 0,
        quantityIssued: li.quantity_issued || 0,
        quantityReturned: li.quantity_returned || 0
      }));
      dryRunReport('deployments/{depId}/items', docs);
    } else {
      for (const li of deploymentItems) {
        const depId = String(li.deployment_id);
        const itemDocId = String(li.id);
        const itemRef = db.collection('deployments').doc(depId).collection('items').doc(itemDocId);
        await itemRef.set({
          id: itemDocId,
          itemId: li.item_id ? String(li.item_id) : null,
          quantityRequested: li.quantity_requested || 0,
          quantityIssued: li.quantity_issued || 0,
          quantityReturned: li.quantity_returned || 0,
          serialNumbers: li.serial_numbers || null,
          notes: li.notes || null
        });
      }
    }
  }

  console.log('Migration done');
}

migrate().catch(err => {
  console.error('Migration failed', err);
  process.exit(1);
});
