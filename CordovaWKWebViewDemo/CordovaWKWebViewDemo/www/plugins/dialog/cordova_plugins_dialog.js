cordova.define("cordova-plugin-dialog-demo", function(require, exports, module) {
     var exec = require('cordova/exec'),
     cordova = require('cordova');
     
     var Dialog = function() {
     };
     
     Dialog.prototype.showMsg = function(successCallback, errorCallback, options) {
         var params = options || {};
         cordova.exec(null, null, 'DialogPlugin', 'showMessage', [params]);
     };
     
     module.exports = new Dialog();
});