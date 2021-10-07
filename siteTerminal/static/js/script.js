//Ici les fonctions pour faire AJAX avec Javascript
function loadDoc(url, cFunction) {
  //la variable ur contient l'id qui est une variable obtenue depuis la BD par Python
  var xhttp;
  xhttp=new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      cFunction(this);
    }
  };
  xhttp.open("GET", url, true);
  xhttp.send();
}
function myFunction(xhttp) {
  document.getElementById("detail").innerHTML =
  xhttp.responseText;
}


//Ici la fonction pour faire AJAX avec JQuery
function loadDocJQuery(url, cFunction) {
   $.ajax({
       url : url,//cette variable contient l'id qui est une variable obtenue depuis la BD par Python
       type : 'GET',
       dataType : 'html', // On désire recevoir du HTML
       success : function(code_html, statut){ // code_html contient le HTML renvoyé
           $('#minmax').html(code_html);
       }
    });
}



