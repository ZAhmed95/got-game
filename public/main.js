// initialize foundation components
$(document).foundation();

var switchThemeInput = document.querySelector("#switch-theme");

function switchTheme(){
  axios.post('/switch-theme');
  document.querySelector("body").classList.toggle("dark");
}