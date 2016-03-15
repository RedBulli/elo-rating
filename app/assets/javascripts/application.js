// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function() {
  function getPlayers() {
    var p1 = $('#player1-selector').val();
    var p2 = $('#player2-selector').val();
    if (p1 !== '' && p2 !== '' && p1 !== p2) {
      return [p1, p2];
    } else {
      return false;
    }
  }

  function round(num) {
    return Math.round(num * 10) / 10;
  }

  function roundEv(num) {
    return Math.round(num * 100) / 100;
  }

  function getEvRepr(playerData) {
    return 'Ev: ' + roundEv(playerData.ev) + '; +' + round(playerData.elo_change_win) + '/' + round(playerData.elo_change_lose);
  }

  function getChangeRepr(eloChange) {
    if (eloChange >= 0) {
      return '+' + eloChange;
    } else {
      return '-' + eloChange;
    }
  }

  $('.player-selector').change(function(event) {
    var players = getPlayers();
    if (players) {
      $.get('/ev?player1=' + players[0] + '&player2=' + players[1], function(result) {
        $('#player1_ev').html(getEvRepr(result.player1));
        $('#player2_ev').html(getEvRepr(result.player2));
      });
    }
  });
});
