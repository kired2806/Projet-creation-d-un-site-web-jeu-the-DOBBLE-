#!/usr/bin/env python
# -*- coding: utf-8 -*-
from flask import Flask, render_template, Markup, request
import cx_Oracle
import datetime
from sqlalchemy import create_engine

#############
username = "VDT2922A"  # remplaces user par ton nom d'utilisateur
#############
password = "fde219562"  # remplaces mdp par ton mot de passe
#############
engine = create_engine(
    "oracle://" + username + ":" + password + "@telline.univ-tlse3.fr:1521/etupre"
)

app = Flask(__name__)


@app.route("/")
def index_page():
    code_html = ""
    strSQL = "select Commande.IDCO, Commande.DATEC, Client.PRENOMC, Client.NOMC from Commande, Client where Commande.IDC=Client.IDC"
    with engine.connect() as con:
        rs = con.execute(strSQL)
        for row in rs:
            code_html += "<tr>"
            for value in row:
                code_html += "<td>" + str(value) + "</td>"
            # Ici un exemple pour : (1) passer une variable (row) de Python vers Javascript, (2) faire appel une fonction Javascript (myFuction) qui travail en configuration AJAX et (3) permettre à l'onclick de commuquer avec Python (id est reçu pour Python dans getDetail)
            code_html += (
                '<td><button type="button" onclick="loadDoc(\'/getDetail?id='
                + str(row[0])
                + "', myFunction)\">Afficher detail</button></td>"
            )
            # Ici un exemple pour : pareil que l'exemple precedent, mais avec JQuery dans la fonction Javascript
            code_html += (
                '<td><button type="button" onclick="loadDocJQuery(\'/getMinMax?date='
                + str(row[1])
                + "')\">Afficher MinMax</button></td>"
            )
            code_html += "</tr>"
    return render_template("index.html", content=Markup(code_html))


@app.route("/getDetail")
def detail_page():
    # Ici un exemple pour la partie dynamique d'AJAX. getDetail reçoit la variable id et puis el est utilisé pour interroger la BD
    myid = request.args.get("id")
    print(myid)
    strSQL = (
        "select Detail.NOMBRE, Produit.NOMP, Produit.PRIXP from Detail, Produit where Detail.IDP=Produit.IDP and Detail.IDCO="
        + myid
    )
    code_html = ""
    with engine.connect() as con:
        rs = con.execute(strSQL)
        for row in rs:
            code_html += "<tr>"
            for value in row:
                code_html += "<td>" + str(value) + "</td>"
            code_html += "</tr>"
    return render_template("getDetail.html", content=Markup(code_html))


@app.route("/getMinMax")
def minmax_page():
    # Ici un exemple pour: (1) la partie dynamique d'AJAX - getMaxMin reçoit la variable date, (2) interroger la BD en utilisant un procedure avec des variables IN et OUT
    mydate = datetime.datetime.strptime(
        request.args.get("date"), "%Y-%m-%d %H:%M:%S"
    )  # variable IN
    print(mydate)
    connection = engine.raw_connection()
    try:
        cursor = connection.cursor()
        a = cursor.var(cx_Oracle.NUMBER)  # variable OUT
        b = cursor.var(cx_Oracle.NUMBER)  # variable OUT
        cursor.callproc("min_max_ventes", [mydate, a, b])
        cursor.close()
        connection.commit()
    finally:
        connection.close()
    code_html = (
        "<tr><td>" + str(a.values[0]) + "</td><td>" + str(b.values[0]) + "</td></tr>"
    )
    return render_template("getMinMax.html", content=Markup(code_html))


if __name__ == "__main__":
    app.run()
