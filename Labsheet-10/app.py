"""
Lab Sheet 10 - Hospital Medicine Management System
HTML -> Flask -> PyMongo -> MongoDB -> Document
Covers Q1 - Q13: add, view, search (ID or name), update stock, delete, low stock,
query practice, embedded supplier documents and an inventory report.

Run:   pip install -r requirements.txt
       python app.py          then open http://127.0.0.1:5000
MongoDB must be running locally (default mongodb://localhost:27017).
"""
import re
from flask import Flask, render_template, request, redirect, url_for, flash
from pymongo import MongoClient
from pymongo.errors import PyMongoError, ServerSelectionTimeoutError

app = Flask(__name__)
app.secret_key = "change-this-secret"

LOW_STOCK_LIMIT = 30          # "low stock" means stock below this number

# ---------------------------------------------------------------- Q4: connection
client = MongoClient("mongodb://localhost:27017", serverSelectionTimeoutMS=3000)
db = client["HospitalDB"]
medicines = db["medicines"]

NO_ID = {"_id": 0}            # projection: hide MongoDB's internal _id in pages


def check_connection():
    try:
        client.admin.command("ping")
        return True, "Successfully connected to MongoDB (HospitalDB.medicines)"
    except ServerSelectionTimeoutError:
        return False, "Could not connect to MongoDB. Is the MongoDB service running?"
    except PyMongoError as exc:
        return False, f"MongoDB error: {exc}"


# ---------------------------------------------------------------- Home
@app.route("/")
def home():
    ok, message = check_connection()
    count = medicines.count_documents({}) if ok else 0
    return render_template("home.html", ok=ok, message=message, count=count)


# ---------------------------------------------------------------- Q2/Q5: add
@app.route("/add", methods=["GET", "POST"])
def add_medicine():
    if request.method == "POST":
        try:
            doc = {
                "medicine_id": int(request.form["medicine_id"]),
                "name": request.form["name"].strip(),
                "category": request.form["category"].strip(),
                "price": float(request.form["price"]),
                "stock": int(request.form["stock"]),
                "manufacturer": request.form["manufacturer"].strip(),
            }
        except ValueError:
            flash("Medicine ID, Price and Stock must be numbers.", "error")
            return redirect(url_for("add_medicine"))

        # Q11: optional embedded supplier document
        s_name = request.form.get("supplier_name", "").strip()
        s_phone = request.form.get("supplier_phone", "").strip()
        s_city = request.form.get("supplier_city", "").strip()
        if s_name or s_phone or s_city:
            doc["supplier"] = {"name": s_name, "phone": s_phone, "city": s_city}

        if medicines.find_one({"medicine_id": doc["medicine_id"]}):
            flash(f"Medicine ID {doc['medicine_id']} already exists.", "error")
            return redirect(url_for("add_medicine"))
        medicines.insert_one(doc)
        flash(f"Medicine {doc['name']} added successfully.", "success")
        return redirect(url_for("view_medicines"))
    return render_template("add.html")


# ---------------------------------------------------------------- Q6: view all
@app.route("/medicines")
def view_medicines():
    data = list(medicines.find({}, NO_ID).sort("medicine_id", 1))
    return render_template("medicines.html", medicines=data, title="All Medicines")


# ---------------------------------------------------------------- Q7: search
@app.route("/search", methods=["GET", "POST"])
def search_medicine():
    results, searched = [], False
    if request.method == "POST":
        searched = True
        term = request.form["term"].strip()
        if term.isdigit():                                  # a number -> search by Medicine ID
            query = {"medicine_id": int(term)}
        else:                                               # text -> case-insensitive name search
            query = {"name": {"$regex": re.escape(term), "$options": "i"}}
        results = list(medicines.find(query, NO_ID).sort("medicine_id", 1))
    return render_template("search.html", results=results, searched=searched)


# ---------------------------------------------------------------- Q8: update stock
@app.route("/update-stock", methods=["GET", "POST"])
def update_stock():
    updated = None
    if request.method == "POST":
        try:
            mid = int(request.form["medicine_id"])
            new_stock = int(request.form["new_stock"])
            if new_stock < 0:
                raise ValueError
        except ValueError:
            flash("Medicine ID and New Stock must be whole numbers (stock cannot be negative).", "error")
            return redirect(url_for("update_stock"))
        result = medicines.update_one({"medicine_id": mid}, {"$set": {"stock": new_stock}})
        if result.matched_count:
            flash(f"Stock of medicine {mid} updated to {new_stock}.", "success")
            updated = medicines.find_one({"medicine_id": mid}, NO_ID)
        else:
            flash(f"No medicine found with ID {mid}.", "error")
    return render_template("update_stock.html", updated=updated)


# ---------------------------------------------------------------- Q9: delete
@app.route("/delete", methods=["GET", "POST"])
def delete_medicine():
    if request.method == "POST":
        try:
            mid = int(request.form["medicine_id"])
        except ValueError:
            flash("Please enter a numeric Medicine ID.", "error")
            return redirect(url_for("delete_medicine"))
        result = medicines.delete_one({"medicine_id": mid})
        if result.deleted_count:
            still_there = medicines.find_one({"medicine_id": mid})      # verification
            flash(f"Medicine {mid} deleted. Still in database: {'yes' if still_there else 'no'}.", "success")
        else:
            flash(f"No medicine found with ID {mid}.", "error")
        return redirect(url_for("delete_medicine"))
    return render_template("delete.html")


# ---------------------------------------------------------------- Low stock
@app.route("/low-stock")
def low_stock():
    data = list(medicines.find({"stock": {"$lt": LOW_STOCK_LIMIT}}, NO_ID).sort("stock", 1))
    return render_template("medicines.html", medicines=data,
                           title=f"Low Stock Medicines (stock below {LOW_STOCK_LIMIT})")


# ---------------------------------------------------------------- Q10: query practice
@app.route("/queries", methods=["GET", "POST"])
def queries():
    data, title = None, ""
    if request.method == "POST":
        kind = request.form.get("kind")
        value = request.form.get("value", "").strip()
        query, sort_key = {}, "medicine_id"
        if kind == "category":                                    # (a)
            query, title = {"category": value}, f"Category: {value}"
        elif kind == "price_gt_50":                               # (b)
            query, title = {"price": {"$gt": 50}}, "Price greater than 50"
        elif kind == "price_lt_100":                              # (c)
            query, title = {"price": {"$lt": 100}}, "Price less than 100"
        elif kind == "stock_lt_30":                               # (d)
            query, title = {"stock": {"$lt": 30}}, "Stock less than 30"
        elif kind == "manufacturer":                              # (e)
            query, title = {"manufacturer": value}, f"Manufacturer: {value}"
        elif kind == "sort_price":                                # (f)
            sort_key, title = "price", "Sorted by price (low to high)"
        elif kind == "sort_stock":                                # (g)
            sort_key, title = "stock", "Sorted by stock (low to high)"
        else:
            flash("Unknown query.", "error")
            return redirect(url_for("queries"))
        data = list(medicines.find(query, NO_ID).sort(sort_key, 1))
    return render_template("queries.html", medicines=data, title=title)


# ---------------------------------------------------------------- Q11: embedded supplier
@app.route("/suppliers")
def suppliers():
    data = list(medicines.find({"supplier": {"$exists": True}}, NO_ID).sort("medicine_id", 1))
    return render_template("suppliers.html", medicines=data)


# ---------------------------------------------------------------- Q12: inventory report
@app.route("/report")
def report():
    total_medicines = medicines.count_documents({})
    agg = list(medicines.aggregate([{"$group": {"_id": None, "total_stock": {"$sum": "$stock"}}}]))
    total_stock = agg[0]["total_stock"] if agg else 0
    low = list(medicines.find({"stock": {"$lt": LOW_STOCK_LIMIT}}, NO_ID).sort("stock", 1))
    expensive = list(medicines.find({}, NO_ID).sort("price", -1).limit(1))
    cheapest = list(medicines.find({}, NO_ID).sort("price", 1).limit(1))
    return render_template(
        "report.html",
        total_medicines=total_medicines,
        total_stock=total_stock,
        low=low,
        limit=LOW_STOCK_LIMIT,
        expensive=expensive[0] if expensive else None,
        cheapest=cheapest[0] if cheapest else None,
    )


if __name__ == "__main__":
    app.run(debug=True)
