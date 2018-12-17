"use strict";
var connection = null;

var WebSocket = WebSocket || MozWebSocket;

/*
// Implement bootstrap 3 style button loading support
(function($) {
  $.fn.button = function(action) {
    if (action === 'loading' && this.data('loading-text')) {
      this.data('original-text', this.html()).html(this.data('loading-text')).prop('disabled', true);
    }
    if (action === 'reset' && this.data('original-text')) {
      this.html(this.data('original-text')).prop('disabled', false);
    }
    feather.replace();
  };
}(jQuery));
*/

// HTML escaping
var entityMap = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#x27;',
  '/': '&#x2F;',
  '`': '&#x60;',
  '=': '&#x3D;'
};

function escapeHtml(string) {
  return String(string).replace(/[&<>"'`=\/]/g, function (s) {
    return entityMap[s];
  });
}

function displayStatus(message) {
  $('#status-content').html('<div id="status" class="alert alert-warning alert-dismissable fade show" role="alert"><span>' + escapeHtml(message) + '</span><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div>');
}

// Enable and disable buttons based on connection status
var connectedButtonIds = ['systemRestart', 'networkApproach', 'visionUp', 'visionDown', 'visionTerm', 'visionKill', 'systemReadOnly', 'systemWritable'];
var writableButtonIds = ['networkSave'];
var systemStatusIds = ['systemMemoryFree1s', 'systemMemoryFree5s',
                       'systemMemoryAvail1s', 'systemMemoryAvail5s',
                       'systemCpuUser1s', 'systemCpuUser5s',
                       'systemCpuSystem1s', 'systemCpuSystem5s',
                       'systemCpuIdle1s', 'systemCpuIdle5s',
                       'systemNetwork1s', 'systemNetwork5s'];

function displayDisconnected() {
  displayReadOnly();
  $('#connectionBadge').removeClass('badge-primary').addClass('badge-secondary').text('Disconnected');
  $('#visionServiceStatus').removeClass('badge-primary').removeClass('badge-secondary').addClass('badge-dark').text('Unknown Status');
  for (var i = 0; i < connectedButtonIds.length; i++) {
    $('#' + connectedButtonIds[i]).prop('disabled', true);
  }
  for (var i = 0; i < systemStatusIds.length; i++) {
    $('#' + systemStatusIds[i]).text("");
  }
}

function displayConnected() {
  $('#connectionBadge').removeClass('badge-secondary').addClass('badge-primary').text('Connected');
  for (var i = 0; i < connectedButtonIds.length; i++) {
    $('#' + connectedButtonIds[i]).prop('disabled', false);
  }
}

// Enable and disable buttons based on writable status
function displayReadOnly() {
  for (var i = 0; i < writableButtonIds.length; i++) {
    $('#' + writableButtonIds[i]).prop('disabled', true);
  }
  $('#systemReadOnly').addClass('active').prop('aria-pressed', true);
  $('#systemWritable').removeClass('active').prop('aria-pressed', false);
}

function displayWritable() {
  for (var i = 0; i < writableButtonIds.length; i++) {
    $('#' + writableButtonIds[i]).prop('disabled', false);
  }
  $('#systemReadOnly').removeClass('active').prop('aria-pressed', false);
  $('#systemWritable').addClass('active').prop('aria-pressed', true);
}

// Handle Read-Only and Writable buttons
$('#systemReadOnly').click(function() {
  var $this = $(this);
  if ($this.hasClass('active')) return;
  var msg = {
    type: 'systemReadOnly'
  };
  connection.send(JSON.stringify(msg));
});

$('#systemWritable').click(function() {
  var $this = $(this);
  if ($this.hasClass('active')) return;
  var msg = {
    type: 'systemWritable'
  };
  connection.send(JSON.stringify(msg));
});

// WebSocket automatic reconnection timer
var reconnectTimerId = 0;

// Establish WebSocket connection
function connect() {
  if (connection && connection.readyState !== WebSocket.CLOSED) return;
  var serverUrl = "ws://" + window.location.hostname;
  if (window.location.port !== '') {
    serverUrl += ':' + window.location.port;
  }
  connection = new WebSocket(serverUrl, 'frcvision');
  connection.onopen = function(evt) {
    if (reconnectTimerId) {
      window.clearInterval(reconnectTimerId);
      reconnectTimerId = 0;
    }
    displayConnected();
  };
  connection.onclose = function(evt) {
    displayDisconnected();
    if (!reconnectTimerId) {
      reconnectTimerId = setInterval(function() { connect(); }, 2000);
    }
  };
  // WebSocket incoming message handling
  connection.onmessage = function(evt) {
    var msg = JSON.parse(evt.data);
    switch (msg.type) {
      case 'systemStatus':
        for (var i = 0; i < systemStatusIds.length; i++) {
          $('#' + systemStatusIds[i]).text(msg[systemStatusIds[i]]);
        }
        break;
      case 'visionStatus':
        var elem = $('#visionServiceStatus');
        if (msg.visionServiceStatus) {
          elem.text(msg.visionServiceStatus);
        }
        if (msg.visionServiceEnabled && !elem.hasClass('badge-primary')) {
          elem.removeClass('badge-dark').removeClass('badge-secondary').addClass('badge-primary');
        } else if (!msg.visionServiceEnabled && !elem.hasClass('badge-secondary')) {
          elem.removeClass('badge-dark').removeClass('badge-primary').addClass('badge-secondary');
        }
        break;
      case 'visionLog':
        visionLog(msg.data);
        break;
      case 'networkSettings':
        $('#networkApproach').val(msg.networkApproach);
        $('#networkAddress').val(msg.networkAddress);
        $('#networkMask').val(msg.networkMask);
        $('#networkGateway').val(msg.networkGateway);
        $('#networkDNS').val(msg.networkDNS);
	updateNetworkSettingsView();
        break;
      case 'systemReadOnly':
        displayReadOnly();
        break;
      case 'systemWritable':
        displayWritable();
        break;
      case 'status':
        displayStatus(msg.message);
        break;
    }
  };
}

// Button handlers
$('#systemRestart').click(function() {
  var msg = {
    type: 'systemRestart'
  };
  connection.send(JSON.stringify(msg));
});

$('#visionUp').click(function() {
  var msg = {
    type: 'visionUp'
  };
  connection.send(JSON.stringify(msg));
});

$('#visionDown').click(function() {
  var msg = {
    type: 'visionDown'
  };
  connection.send(JSON.stringify(msg));
});

$('#visionTerm').click(function() {
  var msg = {
    type: 'visionTerm'
  };
  connection.send(JSON.stringify(msg));
});

$('#visionKill').click(function() {
  var msg = {
    type: 'visionKill'
  };
  connection.send(JSON.stringify(msg));
});

$('#visionLogEnabled').change(function() {
  var msg = {
    type: 'visionLogEnabled',
    value: this.checked
  };
  connection.send(JSON.stringify(msg));
});

//
// Vision console output
//
var visionConsole = document.getElementById('visionConsole');
var visionLogEnabled = $('#visionLogEnabled');
var _linesLimit = 100;

/*
function escape_for_html(txt) {
  return txt.replace(/[&<>]/gm, function(str) {
    if (str == "&") return "&amp;";
    if (str == "<") return "&lt;";
    if (str == ">") return "&gt;";
  });
}
*/

function visionLog(data) {
  if (!visionLogEnabled.prop('checked')) {
    return;
  }
  var wasScrolledBottom = (visionConsole.scrollTop === (visionConsole.scrollHeight - visionConsole.offsetHeight));
  var div = document.createElement('div');
  var p = document.createElement('p');
  p.className = 'inner-line';

  // escape HTML tags
  data = escapeHtml(data);
  p.innerHTML = data;

  div.className = 'line';
  div.addEventListener('click', function click() {
    if (this.className.indexOf('selected') === -1) {
      this.className = 'line-selected';
    } else {
      this.className = 'line';
    }
  });

  div.appendChild(p);
  visionConsole.appendChild(div);

  if (visionConsole.children.length > _linesLimit) {
    visionConsole.removeChild(visionConsole.children[0]);
  }

  if (wasScrolledBottom) {
    visionConsole.scrollTop = visionConsole.scrollHeight;
  }
}

// Show details when appropriate for network approach
function updateNetworkSettingsView() {
  if ($('#networkApproach').val() === "dhcp") {
    $('#networkIpDetails').collapse('hide');
  } else {
    $('#networkIpDetails').collapse('show');
  }
}

$('#networkApproach').change(function() {
  updateNetworkSettingsView();
});

// Network Save button handler
$('#networkSave').click(function() {
  var msg = {
    type: 'networkSave',
    networkApproach: $('#networkApproach').val(),
    networkAddress: $('#networkAddress').val(),
    networkMask: $('#networkMask').val(),
    networkGateway: $('#networkGateway').val(),
    networkDNS: $('#networkDNS').val()
  };
  connection.send(JSON.stringify(msg));
});

// Show details when appropriate for NT client
$('#visionClient').change(function() {
  if (this.checked) {
    $('#visionClientDetails').collapse('show');
  } else {
    $('#visionClientDetails').collapse('hide');
  }
});

// Update view from data structure
var visionSettings = {
  team: '294',
  ntmode: 'client',
  cameras: []
};

function updateVisionSettingsCameraView(cardElem, data) {
}

function updateVisionSettingsView() {
  $('#visionClient').prop('checked', visionSettings.ntmode === 'client');
  if (visionSettings.ntmode === 'client') {
    $('#visionClientDetails').collapse('show');
  } else {
    $('#visionClientDetails').collapse('hide');
  }
  $('#visionTeam').val(visionSettings.team);

  var newCamera = $('#cameraNEW').clone();
  newCamera.find('[id]').each(function() {
    $(this).attr('id', $(this).attr('id').replace('NEW', ''));
  });
  newCamera.find('[for]').each(function() {
    $(this).attr('for', $(this).attr('for').replace('NEW', ''));
  });
}

$('#cameraSettingsFile0').change(function() {
  if (this.files.length <= 0) {
    return false;
  }
  var fr = new FileReader();
  fr.onload = function(e) {
    var result = JSON.parse(e.target.result);
    console.log(result);
  };
  fr.readAsText(this.files.item(0));
});

// Start with display disconnected and start initial connection attempt
displayDisconnected();
updateVisionSettingsView();
connect();
