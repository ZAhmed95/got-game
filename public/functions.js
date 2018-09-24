// this file contains functions specific to each page
// any functions for a specific page are defined within a closure named after that page
// the page in question simply instantiates the closure object, and can then
// use the defined functions

// functions for create_post page
function CreatePost(){
  var dropdown = document.querySelector("#found-games")
  var searchInput = document['game-search-form']['search-game'];
  var games = dropdown.querySelector("#games-list");
  var game_id = document['create-post-form']['game_id'];
  var game_title = document['create-post-form']['game_title'];
  var selectGameButton = document.querySelector("#select-game");
  
  function searchGame(){
    var name = searchInput.value;
    
    axios.post('/search-game', {
      title: name,
    })
    .then((response) => {
      data = response.data;
      games.innerHTML = data;
    })
  }

  function selectGame(event){
    var game = event.target;
    var id = parseInt(game.getAttribute('value'));
    game_id.value = id;
    game_title.value = game.innerText;
    $(dropdown).foundation('close');
  }

  // make "Select Game" button open search game dropdown
  $(selectGameButton).click(function(event) {
    if ($(dropdown).is(':hidden')){
      $(dropdown).foundation('open');
    }
    event.stopPropagation();
  })

  // prevent click from bubbling to window, which will close dropdown
  $(dropdown).click(function(event){
    event.stopPropagation();
  });

  // close dropdown if user clicks anywhere but the dropdown area
  $(window).click(function(event){
    if ($(dropdown).is(':visible')){
      $(dropdown).foundation('close');
    }
  })

  return {
    searchGame,
    selectGame
  }
}
