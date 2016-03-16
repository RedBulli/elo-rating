$(document).ready(function() {
  function getPlayers() {
    var p1 = $('#player1-selector').val();
    var p2 = $('#player2-selector').val();
    if (p1 && p2 && p1 !== p2) {
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

  function updateEvs(players) {
    $.get('/ev?player1=' + players[0] + '&player2=' + players[1], function(result) {
      $('#player1_ev').html(getEvRepr(result.player1));
      $('#player2_ev').html(getEvRepr(result.player2));
      if (result.should_change_breaker) showBreakerChange();
      else hideBreakerChange();
    });
  }

  function showBreakerChange() {
    var el = $('<i class="fa fa-refresh"></i>');
    el.on('click', function() {
      var p1Val = $('#player1-selector').val();
      $('#player1-selector').val($('#player2-selector').val());
      $('#player2-selector').val(p1Val);
      $('#player1-selector').change();
    });
    $('#breaker-change').html('Change breaker! ');
    $('#breaker-change').append(el);
  }

  function hideBreakerChange() {
    $('#breaker-change').html('');
  }

  $('.player-selector').change(function(event) {
    var players = getPlayers();
    if (players) updateEvs(players);
  });
});
