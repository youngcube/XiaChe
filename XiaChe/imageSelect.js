functionsetImageClickFunction(){

varimgs = document.getElementsByTagName("img");

for(vari=0;i

varsrc = imgs[i].src;

imgs[i].setAttribute("onClick","getImg(src)");

}

document.location = imageurls;}

functiongetImg(src){

varurl=src;

document.location = url;

}