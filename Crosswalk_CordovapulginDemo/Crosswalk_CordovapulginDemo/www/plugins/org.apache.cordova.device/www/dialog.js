cordova.define("org.apache.cordova.yincheng.dialog", function(require, exports, module) {
   var exec = require('cordova/exec');
   cordova = require('cordova');

   function Dialog() {
   }
   Dialog.prototype.dialogMessage = function(params) {
       params = params || {};
       exec(null, null, "ObjectiveC_Dialog", "showMessage", [params]);
   }
   module.exports = new Dialog();
});
