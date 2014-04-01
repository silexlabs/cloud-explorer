package ce.core.service;

import ce.core.config.Config;

class UnifileSrv {

	public function new(config : Config) : Void {

		this.config = config;
	}

	var config : Config;
}