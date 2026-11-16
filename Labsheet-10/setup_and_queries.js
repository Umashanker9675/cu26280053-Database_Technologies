// Lab Sheet 10 - Q1, Q10, Q11 : MongoDB shell (mongosh) commands
// Run with:  mongosh < setup_and_queries.js     (or paste into MongoDB Compass > mongosh)

// ---------------- Q1 : database HospitalDB, collection medicines (8 documents)
use HospitalDB
db.medicines.drop()
db.medicines.insertMany([
  { medicine_id: 301, name: "Paracetamol",  category: "Analgesic",    price: 25,  stock: 100, manufacturer: "ABC Pharma" },
  { medicine_id: 302, name: "Amoxicillin",  category: "Antibiotic",   price: 80,  stock: 50,  manufacturer: "MediCure" },
  { medicine_id: 303, name: "Cetirizine",   category: "Antihistamine",price: 35,  stock: 75,  manufacturer: "HealWell" },
  { medicine_id: 304, name: "Omeprazole",   category: "Antacid",      price: 60,  stock: 40,  manufacturer: "ABC Pharma" },
  { medicine_id: 305, name: "Azithromycin", category: "Antibiotic",   price: 120, stock: 25,  manufacturer: "MediCure" },
  { medicine_id: 306, name: "Ibuprofen",    category: "Analgesic",    price: 45,  stock: 20,  manufacturer: "HealWell" },
  { medicine_id: 307, name: "Metformin",    category: "Antidiabetic", price: 30,  stock: 90,  manufacturer: "LifeLine" },
  { medicine_id: 308, name: "Pantoprazole", category: "Antacid",      price: 55,  stock: 28,  manufacturer: "LifeLine" }
])
db.medicines.createIndex({ medicine_id: 1 }, { unique: true })
db.medicines.find().pretty()          // verify
db.medicines.countDocuments()         // 8

// ---------------- Q10 : query practice
db.medicines.find({ category: "Antibiotic" })               // (a) particular category
db.medicines.find({ price: { $gt: 50 } })                   // (b) costing more than 50
db.medicines.find({ price: { $lt: 100 } })                  // (c) costing less than 100
db.medicines.find({ stock: { $lt: 30 } })                   // (d) stock less than 30
db.medicines.find({ manufacturer: "ABC Pharma" })           // (e) particular manufacturer
db.medicines.find().sort({ price: 1 })                      // (f) sort by price (1 = ascending, -1 = descending)
db.medicines.find().sort({ stock: 1 })                      // (g) sort by stock

// ---------------- Q11 : embedded supplier document (name, phone, city)
db.medicines.insertMany([
  { medicine_id: 309, name: "Salbutamol", category: "Bronchodilator", price: 70, stock: 60,
    manufacturer: "ABC Pharma",
    supplier: { name: "Sharma Medical Agency", phone: "9876543210", city: "Agra" } },
  { medicine_id: 310, name: "Diclofenac", category: "Analgesic", price: 40, stock: 35,
    manufacturer: "HealWell",
    supplier: { name: "City Pharma Distributors", phone: "9812345678", city: "Delhi" } },
  { medicine_id: 311, name: "Ranitidine", category: "Antacid", price: 20, stock: 45,
    manufacturer: "LifeLine",
    supplier: { name: "Gupta Drug House", phone: "9900112233", city: "Lucknow" } }
])
db.medicines.find({ supplier: { $exists: true } })          // medicines with supplier info
db.medicines.find({ "supplier.city": "Agra" })              // query inside the embedded document

// ---------------- CRUD one-liners used by the app
db.medicines.findOne({ medicine_id: 301 })                                   // search by ID
db.medicines.find({ name: { $regex: "para", $options: "i" } })               // search by name
db.medicines.updateOne({ medicine_id: 301 }, { $set: { stock: 150 } })       // update stock
db.medicines.deleteOne({ medicine_id: 308 })                                 // delete

// ---------------- Q12 : inventory report queries
db.medicines.countDocuments()                                                // total medicines
db.medicines.aggregate([{ $group: { _id: null, total_stock: { $sum: "$stock" } } }])   // total stock
db.medicines.find({ stock: { $lt: 30 } })                                    // low stock
db.medicines.find().sort({ price: -1 }).limit(1)                             // most expensive
db.medicines.find().sort({ price: 1 }).limit(1)                              // cheapest
