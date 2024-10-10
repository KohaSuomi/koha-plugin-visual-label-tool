/// ALKU ///
/// Niteiden lisäys tarratulostusjonoon. Ilman näitä niteitä ei saa vietyä niteiden muokkauksesta ja perustiedot-näytöltä omaan tulostusjonoon. ///

$(document).ready(function () {
  $(".print_label").after('<li><a href="#" onclick="setPrintQueue($(this))">Tulostusjonoon</a></li>');
  $(".print_label").hide();
  $("#addnewitem").after('<input type="button" style="margin-left:3px;" value="Tulostusjonoon" onclick="setPrintQueue($(this))"/>');

});

function setPrintQueue(element) {
  let searchParams = new URLSearchParams(element.parent().parent().find(".print_label a").attr("href"));
  let itemnumber = element.parent().find('input[name="itemnumber"]').val();
  let number = itemnumber ? itemnumber : searchParams.get('number_list');
  $.ajax({
    url: "/api/v1/contrib/kohasuomi/labels/print/queue",
    type: "POST",
    async: false,
    dataType: "json",
    contentType: "application/json; charset=utf-8",
    data: JSON.stringify({ itemnumber: number, printed: 0 }),
    success: function (result) {
      alert("Nide lisätty jonoon!");
    },
    error: function (err) {
      alert("Lisäys epäonnistui!");
    }
  });
}

/* Niteiden lisätys tarratulostustyökaluun perustiedot-näytöltä */
$(document).ready(function () {
  $("#holdings .itemselection_action_modify, #otherholdings .itemselection_action_modify").after(' <a href="#" class="itemselection_action_print" onclick="addItemsToPrintQueue(event, $(this))"><i class="fa fa-print"></i> Lisää valitut niteet tulostusjonoon</a>');
});
function addItemsToPrintQueue(e, element) {
  e.preventDefault();
  var requests = [];
  $("input[name='itemnumber'][type='checkbox']:visible:checked", 'table.items_table').each(function () {
    var itemnumber = $(this).val();
    requests.push($.ajax({
      url: "/api/v1/contrib/kohasuomi/labels/print/queue",
      type: "POST",
      async: false,
      datatype: "json",
      contentType: "application/json; charset=utf-8",
      data: JSON.stringify({ itemnumber: itemnumber, printed: 0 }),
      error: function (err) {
        console.error(`Niteen nro. ${itemnumber} lisäys tulostusjonoon epäonnistui.`);
      }
    }));
  });
  window.onbeforeunload = function () {
    if (requests.length) {
      return "";
    }
  };
  $('.itemselection_action_print').replaceWith(`<a class="itemselection_action_print disabled" style="cursor: not-allowed;"><i class="fa fa-print"></i> Lisätään ${requests.length} nide${requests.length == 1 ? "" : "ttä"} tulostusjonoon...</a>`);
  $.when.apply($, requests).done(function () {
    alert(`${requests.length} nide${requests.length == 1 ? "" : "ttä"} lisätty tulostusjonoon.`);
  }).fail(function () {
    alert("Niteiden lisäys tulostusjonoon keskeytyi. Tarkista tulostusjono.");
  }).always(function () {
    $('.itemselection_action_print').replaceWith('<a href="#" class="itemselection_action_print" onclick="addItemsToPrintQueue(event, $(this))"><i class="fa fa-print"></i> Lisää valitut niteet tulostusjonoon</a>');
    requests = [];
  });
}

/// LOPPU ///