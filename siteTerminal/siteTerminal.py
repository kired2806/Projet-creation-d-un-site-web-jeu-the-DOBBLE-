from flask import Flask, render_template, Markup, request, session

app = Flask(__name__)
app.secret_key = "super secret key"


@app.route("/")
def index_page():
    print(session)
    code_html = ""
    value = []
    if "value" in session:
        value = session["value"].split("<br>")
    if "value" in request.args:
        if request.args.get("value") == "clear":
            session.pop("value", None)
            value = []
        else:
            value += [request.args.get("value")]
    if len(value) > 0:
        value = "<br>".join(value)
        session["value"] = value
        code_html = value
    return render_template("index.html", content=Markup(code_html))


@app.route("/test1")
def test1_page():
    cartes = ["static/img/images" + x + ".jpeg" for x in ["1", "2"]]
    return render_template("copy.html", cartes=cartes)


if __name__ == "__main__":
    app.debug = True
    app.run()
