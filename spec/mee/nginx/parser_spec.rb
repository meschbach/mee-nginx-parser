require 'spec_helper'

describe MEE::Nginx::Parser do
  it 'has a version number' do
    expect(MEE::Nginx::Parser::VERSION).not_to be nil
  end

	it 'parses statements apart' do
		commands = MEE::Nginx::Parser.parse( %{
server test;
listen *:80;
} ).as_command_strings
		expect( commands ).to include( "server test" )
		expect( commands ).to include( "listen *:80" )
		expect( commands.count ).to be(2)
	end

	it 'parses blocks' do
		commands = MEE::Nginx::Parser.parse( %{
server {
	listen *:443;
}
})
		server_commands = commands.blocks_named("server")
		expect( server_commands[0].is_block? ).to be_truthy
	end

	it 'parses blocks of blocks' do
		commands = MEE::Nginx::Parser.parse( %{
server {
	listen *:443;

	location / {
		max_upload_size 64M;
		max_request_size 128M;
		proxy_pass http://localservice.invalid;
	}
}
})
		expect( commands.path_exists?([ "server", "location /", "max_request_size 128M" ]) ).to be true
	end

	it 'reports non-existent command does not exist' do
		commands = MEE::Nginx::Parser.parse( %{
      upstream test-https {
      	 server localhost:9999; 
      }
      
      
      server {
      	listen *:443 ssl http2;
      	server_name https.etcd2.cnp.invalid;
      
      	include tls_config;
      	ssl_certificate /private/certificate;
      	ssl_certificate_key /private/key;
      
      	location / {
      		proxy_pass http://test-https;
      		include proxy_params;
      	}
      
      	
      }
} )
		expect( commands.path_exists?([ "server", "key /rsc/https/example.key" ]) ).to be false
	end

	it 'reports existent command does exist' do
		commands = MEE::Nginx::Parser.parse( %{
      upstream test-https {
      	 server localhost:9999; 
      }
      
      
      server {
      	listen *:443 ssl http2;
      	server_name https.etcd2.cnp.invalid;
      
      	include tls_config;
      	ssl_certificate /private/certificate;
      	ssl_certificate_key /private/key;
      
      	location / {
      		proxy_pass http://test-https;
      		include proxy_params;
      	}
      
      	
      }
} )
		expect( commands.path_exists?([ "server", "ssl_certificate /private/certificate" ]) ).to be true
	end
end
