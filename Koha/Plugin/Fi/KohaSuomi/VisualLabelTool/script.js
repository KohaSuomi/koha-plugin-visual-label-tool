// --- TRANSLATIONS ---
const LABEL_TOOL_TRANSLATIONS = {
  "en": {
    add_to_queue: "Add to print queue",
    item_added: "Item added to queue!",
    add_failed: "Adding failed!",
    add_selected_to_queue: "Add selected items to print queue",
    adding_items: n => `Adding ${n} item${n == 1 ? "" : "s"} to print queue...`,
    items_added: n => `${n} item${n == 1 ? "" : "s"} added to print queue.`,
    add_cancelled: "Adding items to print queue was interrupted. Check the print queue.",
    add_failed_item: n => `Adding item no. ${n} to print queue failed.`
  },
  "fi": {
    add_to_queue: "Tulostusjonoon",
    item_added: "Nide lisätty jonoon!",
    add_failed: "Lisäys epäonnistui!",
    add_selected_to_queue: "Lisää valitut niteet tulostusjonoon",
    adding_items: n => `Lisätään ${n} nide${n == 1 ? "" : "ttä"} tulostusjonoon...`,
    items_added: n => `${n} nide${n == 1 ? "" : "ttä"} lisätty tulostusjonoon.`,
    add_cancelled: "Niteiden lisäys tulostusjonoon keskeytyi. Tarkista tulostusjono.",
    add_failed_item: n => `Niteen nro. ${n} lisäys tulostusjonoon epäonnistui.`
  },
  "sv": {
    add_to_queue: "Lägg till i utskriftskön",
    item_added: "Exemplar tillagt i kön!",
    add_failed: "Tillägg misslyckades!",
    add_selected_to_queue: "Lägg till valda exemplar i utskriftskön",
    adding_items: n => `Lägger till ${n} exemplar i utskriftskön...`,
    items_added: n => `${n} exemplar tillagda i utskriftskön.`,
    add_cancelled: "Tillägg av exemplar till utskriftskön avbröts. Kontrollera utskriftskön.",
    add_failed_item: n => `Tillägg av exemplar nr. ${n} till utskriftskön misslyckades.`
  }
};

function lt(key, ...args) {
  // Detect language, default to 'en'
  const lang = (window.LANG || navigator.language || "en").substring(0,2);
  const dict = LABEL_TOOL_TRANSLATIONS[lang] || LABEL_TOOL_TRANSLATIONS["en"];
  const val = dict[key];
  return typeof val === "function" ? val(...args) : val;
}

// --- ORIGINAL SCRIPT WITH TRANSLATIONS ---

$(document).ready(function () {
  $(".print_label").after(`<li><a href="#" onclick="setPrintQueue($(this))">${lt("add_to_queue")}</a></li>`);
  $(".print_label").hide();
  $("#addnewitem").after(`<input type="button" style="margin-left:3px;" value="${lt("add_to_queue")}" onclick="setPrintQueue($(this))"/>`);
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
      alert(lt("item_added"));
    },
    error: function (err) {
      alert(lt("add_failed"));
    }
  });
}

/* Niteiden lisätys tarratulostustyökaluun perustiedot-näytöltä */
$(document).ready(function () {
  $("#holdings_panel .itemselection_action_modify, #otherholdings .itemselection_action_modify").after(` <a href="#" class="itemselection_action_print" onclick="addItemsToPrintQueue(event, $(this))"><i class="fa fa-print"></i>${lt("add_selected_to_queue")}</a>`);
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
        console.error(lt("add_failed_item", itemnumber));
      }
    }));
  });
  window.onbeforeunload = function () {
    if (requests.length) {
      return "";
    }
  };
  $('.itemselection_action_print').replaceWith(`<a class="itemselection_action_print disabled" style="cursor: not-allowed;"><i class="fa fa-print"></i> ${lt("adding_items", requests.length)}</a>`);
  $.when.apply($, requests).done(function () {
    alert(lt("items_added", requests.length));
  }).fail(function () {
    alert(lt("add_cancelled"));
  }).always(function () {
    $('.itemselection_action_print').replaceWith(`<a href="#" class="itemselection_action_print" onclick="addItemsToPrintQueue(event, $(this))"><i class="fa fa-print"></i> ${lt("add_selected_to_queue")}</a>`);
    requests = [];
  });
}