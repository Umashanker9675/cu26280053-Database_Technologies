"""
Lab Sheet 9 - Student Record Management System
HTML -> Flask -> PyMongo -> MongoDB -> Document
Covers Q1 - Q12 (setup check, connection, add, view, search, update, delete, filters).

Run:   pip install -r requirements.txt
       python app.py          then open http://127.0.0.1:5000
MongoDB must be running locally (default mongodb://localhost:27017).
"""
from flask import Flask, render_template, request, redirect, url_for, flash
from pymongo import MongoClient
from pymongo.errors import PyMongoError, ServerSelectionTimeoutError

app = Flask(__name__)
app.secret_key = "change-this-secret"        # needed for flash() messages

# ---------------------------------------------------------------- Q5: connection
MONGO_URI = "mongodb://localhost:27017"
client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=3000)
db = client["CollegeDB"]
students = db["students"]


def check_connection():
    """Return (True, message) when MongoDB answers, otherwise (False, error text)."""
    try:
        client.admin.command("ping")
        return True, "Successfully connected to MongoDB (CollegeDB.students)"
    except ServerSelectionTimeoutError:
        return False, "Could not connect to MongoDB. Is the MongoDB service running?"
    except PyMongoError as exc:
        return False, f"MongoDB error: {exc}"


def read_form():
    """Read and convert the form fields (used by add and update)."""
    return {
        "student_id": int(request.form["student_id"]),
        "name": request.form["name"].strip(),
        "age": int(request.form["age"]),
        "gender": request.form["gender"],
        "department": request.form["department"].strip(),
        "marks": float(request.form["marks"]),
    }


# ---------------------------------------------------------------- Home
@app.route("/")
def home():
    ok, message = check_connection()
    count = students.count_documents({}) if ok else 0
    return render_template("home.html", ok=ok, message=message, count=count)


# ---------------------------------------------------------------- Q3/Q6: add
@app.route("/add", methods=["GET", "POST"])
def add_student():
    if request.method == "POST":
        try:
            doc = read_form()
        except ValueError:
            flash("Student ID, Age and Marks must be numbers.", "error")
            return redirect(url_for("add_student"))
        if students.find_one({"student_id": doc["student_id"]}):
            flash(f"Student ID {doc['student_id']} already exists.", "error")
            return redirect(url_for("add_student"))
        students.insert_one(doc)
        flash(f"Student {doc['name']} added successfully.", "success")
        return redirect(url_for("view_students"))
    return render_template("add.html")


# ---------------------------------------------------------------- Q7: view all
@app.route("/students")
def view_students():
    data = list(students.find({}, {"_id": 0}).sort("student_id", 1))
    return render_template("students.html", students=data, title="All Students")


# ---------------------------------------------------------------- Q8: search
@app.route("/search", methods=["GET", "POST"])
def search_student():
    student, searched = None, False
    if request.method == "POST":
        searched = True
        try:
            sid = int(request.form["student_id"])
            student = students.find_one({"student_id": sid}, {"_id": 0})
        except ValueError:
            flash("Please enter a numeric Student ID.", "error")
            searched = False
    return render_template("search.html", student=student, searched=searched)


# ---------------------------------------------------------------- Q9: update
@app.route("/update", methods=["GET", "POST"])
def update_student():
    student = None
    if request.method == "POST":
        action = request.form.get("action")
        try:
            sid = int(request.form["student_id"])
        except ValueError:
            flash("Please enter a numeric Student ID.", "error")
            return redirect(url_for("update_student"))

        if action == "load":                               # step 1: fetch the record
            student = students.find_one({"student_id": sid}, {"_id": 0})
            if not student:
                flash(f"No student found with ID {sid}.", "error")
        else:                                              # step 2: save the changes
            try:
                changes = {
                    "name": request.form["name"].strip(),
                    "age": int(request.form["age"]),
                    "department": request.form["department"].strip(),
                    "marks": float(request.form["marks"]),
                }
            except ValueError:
                flash("Age and Marks must be numbers.", "error")
                return redirect(url_for("update_student"))
            result = students.update_one({"student_id": sid}, {"$set": changes})
            if result.matched_count:
                flash(f"Student {sid} updated.", "success")
                student = students.find_one({"student_id": sid}, {"_id": 0})  # verify
            else:
                flash(f"No student found with ID {sid}.", "error")
    return render_template("update.html", student=student)


# ---------------------------------------------------------------- Q10: delete
@app.route("/delete", methods=["GET", "POST"])
def delete_student():
    if request.method == "POST":
        try:
            sid = int(request.form["student_id"])
        except ValueError:
            flash("Please enter a numeric Student ID.", "error")
            return redirect(url_for("delete_student"))
        result = students.delete_one({"student_id": sid})
        if result.deleted_count:
            flash(f"Student {sid} deleted successfully.", "success")
        else:
            flash(f"No student found with ID {sid}.", "error")
        return redirect(url_for("delete_student"))
    return render_template("delete.html")


# ---------------------------------------------------------------- Q11: filters
@app.route("/filter", methods=["GET", "POST"])
def filter_students():
    data, title = None, ""
    if request.method == "POST":
        kind = request.form.get("kind")
        query = None
        if kind == "department":                                       # (a)
            dept = request.form.get("department", "").strip()
            query, title = {"department": dept}, f"Students in {dept}"
        elif kind == "marks_gt_75":                                    # (b)
            query, title = {"marks": {"$gt": 75}}, "Students with marks greater than 75"
        elif kind == "marks_50_80":                                    # (c)
            query = {"marks": {"$gte": 50, "$lte": 80}}
            title = "Students with marks between 50 and 80"
        elif kind == "age_gt_20":                                      # (d)
            query, title = {"age": {"$gt": 20}}, "Students older than 20"
        if query is not None:
            try:
                data = list(students.find(query, {"_id": 0}).sort("student_id", 1))
            except PyMongoError as exc:
                flash(f"Database error: {exc}", "error")
    return render_template("filter.html", students=data, title=title)


if __name__ == "__main__":
    app.run(debug=True)
