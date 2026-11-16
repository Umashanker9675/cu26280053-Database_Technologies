// Lab Sheet 9 - Q1 & Q2 : MongoDB shell (mongosh) commands
// Run with:  mongosh < setup_and_queries.js     (or paste into MongoDB Compass > mongosh)

// Q2  database CollegeDB, collection students, at least 5 documents
use CollegeDB
db.students.drop()
db.students.insertMany([
  { student_id: 101, name: "Amit Sharma", age: 20, gender: "Male",   department: "Computer Science", marks: 85 },
  { student_id: 102, name: "Priya Singh", age: 21, gender: "Female", department: "Pharmacy",         marks: 92 },
  { student_id: 103, name: "Rahul Verma", age: 19, gender: "Male",   department: "Computer Science", marks: 76 },
  { student_id: 104, name: "Neha Gupta",  age: 22, gender: "Female", department: "Commerce",         marks: 48 },
  { student_id: 105, name: "Arjun Mehta", age: 20, gender: "Male",   department: "Mathematics",      marks: 69 },
  { student_id: 106, name: "Sneha Rao",   age: 21, gender: "Female", department: "Pharmacy",         marks: 95 }
])
db.students.createIndex({ student_id: 1 }, { unique: true })   // one record per Student ID
db.students.find().pretty()                                    // verify the documents
db.students.countDocuments()                                   // 6

// Q11 filtering queries (the Flask app runs the same filters)
db.students.find({ department: "Computer Science" })           // (a) a particular department
db.students.find({ marks: { $gt: 75 } })                       // (b) marks greater than 75
db.students.find({ marks: { $gte: 50, $lte: 80 } })            // (c) marks between 50 and 80
db.students.find({ age: { $gt: 20 } })                         // (d) older than 20

// CRUD one-liners used by the app
db.students.findOne({ student_id: 101 })                                            // search
db.students.updateOne({ student_id: 101 }, { $set: { name: "Amit S.", age: 21, department: "IT", marks: 88 } })  // update
db.students.deleteOne({ student_id: 106 })                                          // delete
