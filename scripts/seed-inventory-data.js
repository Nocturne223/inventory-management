const { initializeApp } = require('firebase/app');
const { getFirestore, collection, addDoc, doc, setDoc } = require('firebase/firestore');

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAb6lTQFfQfvIe0r6LzEPWa5QgNgXxFmds",
  authDomain: "inventory-management-aefea.firebaseapp.com",
  projectId: "inventory-management-aefea",
  storageBucket: "inventory-management-aefea.firebasestorage.app",
  messagingSenderId: "649838509451",
  appId: "1:649838509451:web:42a8dd6b1c7a831c90e8cf",
  measurementId: "G-L0X1LWSMCY"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function seedInventoryData() {
  try {
    console.log('Starting to seed inventory data...');

    // Sample departments
    const departments = [
      {
        id: 'dept_cse',
        code: 'CSE',
        name: 'Computer Science Engineering',
        description: 'Department of Computer Science and Engineering',
        headOfDepartment: 'Dr. Smith',
        createdAt: new Date().toISOString()
      },
      {
        id: 'dept_ece',
        code: 'ECE',
        name: 'Electronics & Communication',
        description: 'Department of Electronics and Communication Engineering',
        headOfDepartment: 'Dr. Johnson',
        createdAt: new Date().toISOString()
      },
      {
        id: 'dept_me',
        code: 'ME',
        name: 'Mechanical Engineering',
        description: 'Department of Mechanical Engineering',
        headOfDepartment: 'Dr. Williams',
        createdAt: new Date().toISOString()
      }
    ];

    // Sample locations
    const locations = [
      {
        id: 'loc_lab1',
        name: 'Computer Lab 1',
        building: 'Main Building',
        room: 'Room 101',
        description: 'Primary computer laboratory',
        createdAt: new Date().toISOString()
      },
      {
        id: 'loc_lab2',
        name: 'Electronics Lab',
        building: 'Engineering Block',
        room: 'Room 205',
        description: 'Electronics and circuits laboratory',
        createdAt: new Date().toISOString()
      },
      {
        id: 'loc_workshop',
        name: 'Mechanical Workshop',
        building: 'Workshop Building',
        room: 'Ground Floor',
        description: 'Mechanical engineering workshop',
        createdAt: new Date().toISOString()
      }
    ];

    // Sample inventory items
    const inventoryItems = [
      {
        name: 'Dell OptiPlex 7090',
        description: 'High-performance desktop computer for laboratory use',
        category: 'Computer',
        brand: 'Dell',
        model: 'OptiPlex 7090',
        serialNumber: 'DL2023001',
        status: 'available',
        price: 899.99,
        purchaseDate: new Date('2023-01-15').toISOString(),
        locationId: 'loc_lab1',
        departmentId: 'dept_cse',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        name: 'HP Laptop ProBook 450',
        description: 'Professional laptop for mobile computing needs',
        category: 'Computer',
        brand: 'HP',
        model: 'ProBook 450 G8',
        serialNumber: 'HP2023002',
        status: 'in-use',
        price: 649.99,
        purchaseDate: new Date('2023-02-20').toISOString(),
        locationId: 'loc_lab1',
        departmentId: 'dept_cse',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        name: 'Digital Oscilloscope',
        description: 'Digital storage oscilloscope for electronic measurements',
        category: 'Electronics',
        brand: 'Tektronix',
        model: 'TBS1052B',
        serialNumber: 'TEK2023003',
        status: 'available',
        price: 459.00,
        purchaseDate: new Date('2023-03-10').toISOString(),
        locationId: 'loc_lab2',
        departmentId: 'dept_ece',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        name: 'Function Generator',
        description: 'Arbitrary waveform generator for signal testing',
        category: 'Electronics',
        brand: 'Keysight',
        model: '33220A',
        serialNumber: 'KEY2023004',
        status: 'maintenance',
        price: 1250.00,
        purchaseDate: new Date('2022-11-05').toISOString(),
        locationId: 'loc_lab2',
        departmentId: 'dept_ece',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        name: 'Lathe Machine',
        description: 'CNC lathe machine for precision machining',
        category: 'Machinery',
        brand: 'Haas',
        model: 'ST-10',
        serialNumber: 'HAAS2023005',
        status: 'available',
        price: 45000.00,
        purchaseDate: new Date('2022-08-15').toISOString(),
        locationId: 'loc_workshop',
        departmentId: 'dept_me',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        name: 'Network Switch',
        description: '24-port managed Gigabit Ethernet switch',
        category: 'Network',
        brand: 'Cisco',
        model: 'Catalyst 2960-X',
        serialNumber: 'CSC2023006',
        status: 'in-use',
        price: 849.99,
        purchaseDate: new Date('2023-01-30').toISOString(),
        locationId: 'loc_lab1',
        departmentId: 'dept_cse',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        name: 'Projector',
        description: 'HD projector for presentations and lectures',
        category: 'Display',
        brand: 'Epson',
        model: 'PowerLite 1781W',
        serialNumber: 'EPS2023007',
        status: 'available',
        price: 399.99,
        purchaseDate: new Date('2023-04-12').toISOString(),
        locationId: 'loc_lab1',
        departmentId: 'dept_cse',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        name: 'Power Supply Unit',
        description: 'Variable DC power supply for electronics testing',
        category: 'Electronics',
        brand: 'BK Precision',
        model: '9184',
        serialNumber: 'BKP2023008',
        status: 'retired',
        price: 299.99,
        purchaseDate: new Date('2020-06-20').toISOString(),
        locationId: 'loc_lab2',
        departmentId: 'dept_ece',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }
    ];

    // Add departments
    console.log('Adding departments...');
    for (const dept of departments) {
      await setDoc(doc(db, 'departments', dept.id), {
        code: dept.code,
        name: dept.name,
        description: dept.description,
        headOfDepartment: dept.headOfDepartment,
        createdAt: dept.createdAt
      });
      console.log(`Added department: ${dept.name}`);
    }

    // Add locations
    console.log('Adding locations...');
    for (const loc of locations) {
      await setDoc(doc(db, 'locations', loc.id), {
        name: loc.name,
        building: loc.building,
        room: loc.room,
        description: loc.description,
        createdAt: loc.createdAt
      });
      console.log(`Added location: ${loc.name}`);
    }

    // Add inventory items
    console.log('Adding inventory items...');
    for (const item of inventoryItems) {
      const docRef = await addDoc(collection(db, 'inventory_items'), {
        name: item.name,
        description: item.description,
        category: item.category,
        brand: item.brand,
        model: item.model,
        serialNumber: item.serialNumber,
        status: item.status,
        price: item.price,
        purchaseDate: item.purchaseDate,
        locationId: item.locationId,
        departmentId: item.departmentId,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt
      });
      console.log(`Added inventory item: ${item.name} (ID: ${docRef.id})`);
    }

    console.log('✅ Successfully seeded all inventory data!');
    console.log('📊 Summary:');
    console.log(`   • ${departments.length} departments`);
    console.log(`   • ${locations.length} locations`);
    console.log(`   • ${inventoryItems.length} inventory items`);

  } catch (error) {
    console.error('❌ Error seeding data:', error);
  }
}

// Run the seeding function
seedInventoryData().then(() => {
  console.log('Seeding completed!');
}).catch((error) => {
  console.error('Seeding failed:', error);
});