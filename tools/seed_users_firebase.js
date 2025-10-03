// Run this in the Firebase console or Firebase Cloud Functions
// This script seeds users to Firestore using the Firebase Admin SDK

const users = [
  // Existing authenticated user
  {
    uid: 'APduHk4yn8TL1W9oahqYI0w4efU2',
    email: 'admin@mit.edu',
    name: 'System Administrator',
    role: 'Admin',
    isActive: true
  },
  // Tech role users
  {
    uid: 'tech_user_001',
    email: 'tech1@mit.edu',
    name: 'Technical Support 1',
    role: 'Tech',
    isActive: true
  },
  {
    uid: 'tech_user_002',
    email: 'tech2@mit.edu',
    name: 'Technical Support 2',
    role: 'Tech',
    isActive: true
  },
  // GSO role users
  {
    uid: 'gso_user_001',
    email: 'gso1@mit.edu',
    name: 'General Services Officer 1',
    role: 'GSO',
    isActive: true
  },
  {
    uid: 'gso_user_002',
    email: 'gso2@mit.edu',
    name: 'General Services Officer 2',
    role: 'GSO',
    isActive: true
  },
  // MIS role user
  {
    uid: 'mis_user_001',
    email: 'mis@mit.edu',
    name: 'Management Information Systems',
    role: 'MIS',
    isActive: true
  },
  // Admin role users
  {
    uid: 'admin_user_002',
    email: 'admin2@mit.edu',
    name: 'Department Administrator',
    role: 'Admin',
    isActive: true
  },
  // SuperAdmin role user
  {
    uid: 'superadmin_user_001',
    email: 'superadmin@mit.edu',
    name: 'Super Administrator',
    role: 'SuperAdmin',
    isActive: true
  },
  // Inactive user for testing
  {
    uid: 'inactive_user_001',
    email: 'inactive@mit.edu',
    name: 'Inactive User',
    role: 'Tech',
    isActive: false
  }
];

// Function to seed users
async function seedUsers() {
  const db = admin.firestore();
  const now = new Date().toISOString();
  
  console.log('🔥 Seeding users with different roles to Firestore...');
  console.log(`📝 Seeding ${users.length} users...`);
  
  for (const user of users) {
    try {
      const userData = {
        email: user.email,
        name: user.name,
        role: user.role,
        createdAt: now,
        lastLoginAt: user.uid === 'APduHk4yn8TL1W9oahqYI0w4efU2' ? now : null,
        isActive: user.isActive
      };
      
      await db.collection('users').doc(user.uid).set(userData);
      console.log(`✅ Successfully seeded user: ${user.email} (${user.role})`);
    } catch (error) {
      console.error(`❌ Failed to seed user ${user.uid}:`, error);
    }
  }
  
  // Print summary
  const roleCounts = users.reduce((acc, user) => {
    acc[user.role] = (acc[user.role] || 0) + 1;
    return acc;
  }, {});
  
  console.log('\n📊 User roles summary:');
  Object.entries(roleCounts).forEach(([role, count]) => {
    console.log(`   ${role}: ${count} users`);
  });
  
  console.log('✅ User seeding completed!');
}

// For Firebase Functions
exports.seedUsers = functions.https.onRequest(async (req, res) => {
  try {
    await seedUsers();
    res.status(200).send('Users seeded successfully');
  } catch (error) {
    console.error('Error seeding users:', error);
    res.status(500).send('Error seeding users');
  }
});

// For direct execution (if using Firebase Admin SDK directly)
if (typeof admin !== 'undefined') {
  seedUsers();
}