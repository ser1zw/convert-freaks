// -*- mode: javascript; coding: utf-8 -*-

function convert() {
    var text = $("#input-data")[0].value;
    var charset = $("#charset")[0].value;

    if (text) {
	$.ajax({
	    type: "post",
	    url: "/api/convert",
	    dataType: "json",
	    data: {
		inputdata: text,
		charset: charset
	    },
	    success: function(data) {
		createResultTable(data);
	    },
	    error: function(req, status, message) {
		alert(message);
	    }
	});
    }
}

function createResultTable(result) {
    function addRecord(tableId, result, dataKey) {
	$(tableId + " tr").remove();
	for (var key in result) {
	    var data = result[key].data[dataKey]
	    if (data != null) {
		var tr = $("<tr></tr>");
		tr.append($("<th></th>").text(result[key].label));
		var textarea = $('<textarea class="result-record"></textarea>').text(data);
		tr.append($("<td></td>").html(textarea));
		$(tableId).append(tr);
	    }
	}
    }
    addRecord("#encode-result", result, "encoded");
    addRecord("#decode-result", result, "decoded");
}

function clearInputData() {
    $("#input-data")[0].value = "";
}

