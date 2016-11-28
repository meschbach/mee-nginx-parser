require 'strscan'
require "mee/nginx/parser/version"

module MEE
  module Nginx
    module Parser
			def self.parse( raw_text )
				scanner = StringScanner.new( raw_text )
				buffer = ParsedBuffer.new
				begin
					 maybe_match = scanner.scan_until( /[\;\{\}]/ )
					 break if maybe_match.nil?
					 token = maybe_match.strip[0..-2].strip
					 matched = scanner.matched

					 if matched == ";"
					 	buffer.consume_statement( token )
					 elsif matched == "\{"
					 	buffer = buffer.begin_block( token )
					 elsif matched == "\}"
					 	buffer = buffer.end_block( token )
					 else
					 	if !scanner.matched? # last bit
							remaining = token.strip
							buffer.consume_statement( remaining ) unless remaining.empty?
						else
							raise "Can't handle token '#{token.strip}' with match '#{scanner.matched.strip}'" unless token.strip.empty?
						end
					 end
				end until scanner.eos?
				buffer
			end

			class CompositeNode
				def initialize()
					@commands = []
				end

				def is_statement?; true; end
				def is_block?; true; end

				def blocks
					@commands.select { |cmd| cmd.is_block? }
				end

				def blocks_named( name )
					blocks.select { |cmd| cmd.text == name }
				end

				def statements
					@commands.select do |cmd|
						cmd.is_statement?
					end
				end

				def statements_named( name )
					statements.select do |cmd|
						cmd.text == name
					end
				end

				def consume_statement( statement )
					@commands.push( CommandStatement.new( statement ) )
				end

				def begin_block( statement )
					block = BlockStatement.new( statement, self )
					@commands.push( block )
					block
				end

				def path_exists?( path )
					name = path.shift
					if path.empty?
						!statements_named( name ).empty?
					else
						blocks_named( name ).any? do |node|
							node.path_exists?( Array.new( path ) )
						end
					end
				end
			end

			class ParsedBuffer < CompositeNode
				def as_command_strings;
					@commands.reject do |cmd|
						!cmd.is_statement?
					end.map do |cmd|
						cmd.text
					end
				end
			end

			class BlockStatement < CompositeNode
				def initialize( statement, parent )
					super()
					@statement = statement
					@parent = parent
				end

				def text; @statement; end

				def end_block( token )
					@parent
				end
			end

			class CommandStatement
				def initialize( statement )
					@statement = statement
				end

				def text; @statement ; end

				def is_statement?; true ; end
				def is_block?; false; end
			end
    end
  end
end
