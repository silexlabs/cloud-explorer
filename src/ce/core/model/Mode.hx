/**
 * Cloud Explorer, lightweight frontend component for file browsing with cloud storage services.
 * @see https://github.com/silexlabs/cloud-explorer
 *
 * Cloud Explorer works as a frontend interface for the unifile node.js module:
 * @see https://github.com/silexlabs/unifile
 *
 * @author Thomas Fétiveau, http://www.tokom.fr  &  Alexandre Hoyau, http://lexoyo.me
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package ce.core.model;

enum Mode {

	SingleFileSelection(onSuccess : CEBlob -> Void, onError : CEError -> Void);
	SingleFileExport(onSuccess : CEBlob -> Void, onError : CEError -> Void, input : CEBlob, options : Null<ce.core.model.api.ExportOptions>);
}