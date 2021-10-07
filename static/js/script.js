function test() {
    gameAction(2);
}

function test2() {
    game.commun(0, 2);
}

function testGenCard() {
    $.ajax({
        data: { id: 2 },
        url: "/gameActionProcess",
        type: "POST",
        success: function (data, statut) {
            $("#RETOUR").html(data.cartes);
            html = "";
            for (carte of data.cartes) {
                html += "<tr>";
                for (symb of carte[1]) {
                    path = symb[2];
                    html += `<td><button><img src="static/${path}" width="100" height="100" /></button></td>`;
                }
                html += "</tr>";
            }
            $("#testCartes").html(html);
        },
    });
}

function inscription() {
    $.ajax({
        data: {
            ndc: $("#INomDeCompte").val(),
            mdp: $("#IMotDePasse").val(),
            pseudo: $("#IPseudo").val(),
            age: $("#IAge").val(),
        },
        type: "POST",
        url: "/inscriptionProcess",
        success: function (data, statut) {
            if (data.success) {
                $("#INomDeCompte").val("");
                $("#IMotDePasse").val("");
                $("#IPseudo").val("");
                $("#IAge").val("");
                $("#MessageInscription").css({ color: "green" });
                $("#MessageInscription").html(data.code_html);
            } else {
                $("#MessageInscription").css({ color: "red" });
                $("#MessageInscription").html(data.error);
            }
        },
    });
}

function connection() {
    $.ajax({
        data: {
            ndc: $("#NomDeCompte").val(),
            mdp: $("#MotDePasse").val(),
        },
        type: "POST",
        url: "/connectionProcess",
        success: function (data, statut) {
            if (data.success) {
                window.location.replace("/");
            } else {
                $("#MessageConnection").css({ color: "red" });
                $("#MessageConnection").html(data.error);
            }
        },
    });
}

function disconnection() {
    $.ajax({
        data: {},
        type: "POST",
        url: "/disconnectionProcess",
        success: function (data, statut) {
            if (data.success) {
                window.alert("Vous avez été déconnecté !");
                window.location.replace("/");
            }
        },
    });
}

function selectGame(lvl = 0) {
    if (lvl == 0) {
        $("#RETOUR").html("AFFICHAGE MENUE DEROULANT");
    } else if (lvl != 0) {
        $("#RETOUR").html(`Selection lvl ${lvl}`);
        $.ajax({
            data: { lvl: lvl },
            type: "POST",
            url: "/selectGameProcess",
            success: function (data, statut) {
                if (data.success) {
                    window.location.replace("/");
                }
            },
        });
    }
}

function gameAction(id) {
    if (id == 0) {
        game.start();
    } else if (id == 1) {
        window.location.replace("/");
    } else if (id == 2) {
        game.init(false);
    } else if (id == 3) {
        $("#RETOUR").html(
            `image ${String(arguments[1])}, ${String(
                arguments[2]
            )} selectionné => ${String(
                game.idSymb(arguments[1], arguments[2])
            )}`
        );
        game.clickOn(arguments[1], arguments[2]);
    }
}

class Symbole {
    constructor(symbole) {
        // alert("CONSTRUCTION SYMBOLE");
        this.id = symbole[0];
        this.position = symbole[1];
        this.path = symbole[2];
    }

    getPath() {
        return this.path;
    }
    getPosition() {
        return this.position;
    }
    getId() {
        return this.id;
    }

    afficher(position) {
        var value = `<img src="static/${this.path}" width="100" height="100" />`;
        if (position == 0) {
            $(`#cJoueur${String(this.position)}`).html(value);
        } else if (position == 1) {
            $(`#cPc${String(this.position)}`).html(value);
        } else if (position == 2) {
            $(`#cPioche${String(this.position)}`).html(value);
        }
    }
}

class Carte {
    constructor(carte) {
        this.symboles = [];
        this.id = carte[0];
        for (var symbole of carte[1]) {
            this.symboles.push(new Symbole(symbole));
        }
    }

    afficher(position) {
        for (var symbole of this.symboles) {
            symbole.afficher(position);
        }
    }

    listSymbId() {
        var listSymbId = [];
        for (var symbole of this.symboles) {
            listSymbId.push(symbole.getId());
        }
        return listSymbId;
    }

    idSymb(position) {
        return this.symboles[position].getId();
    }
}

class Time {
    constructor() {}

    setTime(time) {
        this.time = time; // en millisecondes
    }

    get() {
        return this.time;
    }

    getMinutes() {
        return Math.floor(this.time / 1000 / 60);
    }
    getSeconds() {
        return Math.floor((this.time % (1000 * 60)) / 1000);
    }

    toString() {
        var min = this.getMinutes();
        var sec = this.getSeconds();
        if (min < 10) {
            var Strmin = String(0) + String(min);
        } else {
            var Strmin = String(min);
        }
        if (sec < 10) {
            var Strsec = String(0) + String(sec);
        } else {
            var Strsec = String(sec);
        }
        return `${Strmin}:${Strsec}`;
    }
}

// a Faire:
// liaisons des réponses avec le serveur
// Fin du game
// Cacher les tableau au début et a la fin
// Le bouton démarrer

class Game {
    constructor() {}

    init(view) {
        this.cartes = new Array();
        this.time = new Time();
        this.initOtherData(); // initialise les données récupéré sur le server
        this.piocheCarte = 2;
        this.playerCarte = 0;
        this.pcCarte = 1;
        this.score = 0;
        this.lastChangeTime = 0;
        this.compteurPc = 0;
        this.compteurJoueur = 0;
        this.stop = false;
        if (view) {
            // a Faire pour regarder une partie
            init_view();
        }
    }

    start() {
        this.init(false);
        this.timer();
        this.playPc();
        this.afficherAllCarte();
        this.afficherScore();
        this.afficherCompteurCarte();
        $("#gameInfo").css({ display: "block" });
    }

    initOtherData() {
        $.ajax({
            data: { id: 2 }, // Initialise
            type: "POST",
            url: "/gameActionProcess",
            async: false, // attendre de récupe les donnée avant de continuer sinon probleme d'affichage
            success: function (data, statut) {
                if (data.success) {
                    game.setCartes(data.cartes);
                    game.setTempsOrdiMin(data.TempsOrdiMin);
                    game.setTempsOrdiMax(data.TempsOrdiMax);
                    game.setCoeffScore(data.CoeffScore);
                    game.setMalus(data.Malus);
                }
            },
        });
    }

    setCartes(datacartes) {
        for (var carte of datacartes) {
            this.cartes.push(new Carte(carte));
        }
    }

    setTempsOrdiMin(dataTempsOrdiMin) {
        this.tempsOrdiMin = dataTempsOrdiMin;
    }

    setTempsOrdiMax(dataTempsOrdiMax) {
        this.tempsOrdiMax = dataTempsOrdiMax;
    }

    setCoeffScore(dataCoeffScore) {
        this.coeffScore = dataCoeffScore;
    }

    setMalus(datamalus) {
        this.malus = datamalus;
    }

    afficherCarte(carteNum, position) {
        this.cartes[carteNum].afficher(position);
    }

    clickOn(carte, position) {
        if (
            this.idSymb(carte, position) ==
            this.commun(this.playerCarte, this.piocheCarte)
        ) {
            this.gagnePoint();
            var EstWin = true;
        } else {
            this.perdrePoint();
            var EstWin = false;
        }
        this.actualiseGame(EstWin, true);
    }

    commun(carte1, carte2) {
        var carte1SymbId = this.cartes[carte1].listSymbId();
        var carte2SymbId = this.cartes[carte2].listSymbId();
        for (var i = 0; i < carte1SymbId.length; i++) {
            for (var j = 0; j < carte2SymbId.length; j++) {
                if (carte1SymbId[i] == carte2SymbId[j]) {
                    return carte1SymbId[i];
                }
            }
        }
    }

    idSymb(carte, position) {
        if (carte == 0) {
            return this.cartes[this.playerCarte].idSymb(position);
        }
        return this.cartes[this.piocheCarte].idSymb(position);
    }

    gagnePoint() {
        var actualTime = this.time.get();
        this.score += Math.floor(
            ((100 * this.coeffScore) / (actualTime - this.lastChangeTime)) *
                1000
        );
    }

    perdrePoint() {
        this.score -= this.malus;
    }

    getStop() {
        return this.stop;
    }

    timer() {
        var timer = new Date().getTime();
        var x = setInterval(function () {
            var now = new Date().getTime();
            var distance = now - timer;
            game.setTime(distance);
            game.afficherTimer();
            if (game.getStop()) {
                clearInterval(x);
            }
        }, 1);
    }

    setTime(distance) {
        this.time.setTime(distance);
    }

    afficherTimer() {
        $("#timer").html(this.time.toString());
    }

    actualiseGame(EstWin, player) {
        this.afficherScore();
        if (EstWin) {
            if (player) {
                this.playerCarte = this.piocheCarte;
                this.compteurJoueur += 1;
            } else {
                this.pcCarte = this.piocheCarte;
                this.compteurPc += 1;
            }
            this.lastChangeTime = this.time.get();
            this.piocheCarte += 1;
            if (!this.gameIsEnd()) {
                this.afficherAllCarte();
                this.afficherCompteurCarte();
                this.timeToPlayPc =
                    Math.random() * (this.tempsOrdiMax - this.tempsOrdiMin) +
                    this.tempsOrdiMin +
                    this.time.get() / 1000;
            } else {
                this.afficherCompteurCarte();
                this.gameEnd();
            }
        }
    }

    gameIsEnd() {
        return Boolean(this.piocheCarte >= this.cartes.length);
    }

    playerWin() {
        return Boolean(this.compteurJoueur >= this.compteurPc);
    }

    gameEnd() {
        // cacher les cartes, afficher les résultats + message de win/defaite
        this.stop = true;
        $("#gameInfo").css({ display: "none" });
        if (this.playerWin()) {
            $("#msgEnd").html("YOU WIN !");
            $("#msgEnd").css({ color: "green" });
        } else {
            $("#msgEnd").html("YOU LOOSE !");
            $("#msgEnd").css({ color: "red" });
        }
        $("#timerEnd").html(this.time.toString());
        $("#gameRecap").css({ display: "block" });
    }

    afficherCompteurCarte() {
        $("#compteurPioche > .value").html(
            this.cartes.length - this.piocheCarte
        );
        $("#compteurJoueur > .value").html(this.compteurJoueur);
        $("#compteurPc > .value").html(this.compteurPc);
    }

    afficherAllCarte() {
        this.afficherCarte(this.playerCarte, 0);
        this.afficherCarte(this.pcCarte, 1);
        this.afficherCarte(this.piocheCarte, 2);
    }

    afficherScore() {
        $("#score").html(this.score);
    }

    getStopPc() {
        return this.stopPc;
    }

    getTime() {
        return this.time.get();
    }

    getTimeToPlayPc() {
        return this.timeToPlayPc;
    }

    playPc() {
        var x = setInterval(function () {
            if (game.getStop()) {
                clearInterval(x);
            } else if (game.getTimeToPlayPc() <= game.getTime() / 1000) {
                game.actualiseGame(true, false);
            }
        }, 10);
    }
}
game = new Game();

function review(IdPartie) {}

function fctTest() {
    // alert($("#NomDeCompte").val());
    // alert($("#MotDePasse").val());
    $.ajax({
        data: {
            ndc: $("#NomDeCompte").val(),
            mdp: $("#MotDePasse").val(),
        },
        type: "POST",
        url: "/process",
        success: function (data, statut) {
            if (data.success) {
                alert("Vous êtes connectés");
                $(".connection").css({ display: "none" });
                $("#NomDeCompte").val(""); // Reset NomDeCompte firld
                $("#MotDePasse").val(""); // Reset MotDePasse field
                $("#connected").css({ display: "block" });
                $("#connected").html(data.code_html);
            } else {
                alert(data.success);
            }
        },
    });
}

function wait(ms) {
    var start = new Date().getTime();
    var end = start;
    while (end < start + ms) {
        end = new Date().getTime();
    }
}
