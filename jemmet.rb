require 'pp'  # DEBUG
require 'json'

# {
#   'data types': {
#     'strings': 'This is a string',
#     'number': 123,
#     'big number': 1.2e+100,
#     'boolean true': true,
#     'boolean false': false,
#     'nil': null,
#     'objects': {
#       'What is this?': 'An object.'
#     },
#     'array': [1, 2, 3, 4 ,5],
#   }
# }


# Example:
#
# o>o,a>s*3
#
# {
#   '': {
#
#   },
#   '': ['']
# }

class Jemmet
  class DataType
    def initialize(**options)
      @name = options['name'] || :object
      @start_token = options['start_token'] || '{'
      @stop_token = options['stop_token'] || '}'
      @value = options['value'] || ''
    end
  end

  @split_pattern = />|\+|\^/
  @token_split_pattern = /\.|>|\^|\*|\+/
  @tokens = []
  @data_type_symbols = {
    'o' => DataType.new({:name => :object, :start_token => '{',
                          :stop_token => '}', :value => ''}),
    'a' => DataType.new({:name => :array, :start_token => '[',
                          :stop_token => ']', :value => ''}),
    's' => DataType.new({:name => :string, :start_token => '\'',
                          :stop_token => '\'', :value => ''}),
    'i' => DataType.new({:name => :number, :start_token => '',
                          :stop_token => '', :value => '0'}),
    't' => DataType.new({:name => :true, :start_token => '',
                          :stop_token => '', :value => 'true'}),
    'f' => DataType.new({:name => :false, :start_token => '',
                          :stop_token => '', :value => 'false'}),
    'n' => DataType.new({:name => :null, :start_token => '',
                          :stop_token => '', :value => 'null'}),
  }
  @result = ''

  def self.parse(string)
    # @tokens = s.split(@split_pattern)
    s = ''
    string.split('').each do |token|
      s << token
      if token.match(@split_pattern) != nil
        self.parse_subtoken(s)
        @tokens << s
        s = ''
      end
    end
    PP.pp(@tokens)
  end

  def self.parse_subtoken(token)
    s = ''
    token.split('').each do |t|
      # if !t.match(@token_split_pattern)
      #   s << t
      # end
    end
    name = token.match(/\.\w{1,}/)
    name = name[0].sub(/^\.*/, '') if name != nil

    repetitions = token.match(/\*[0-9]{1,}/)
    repetitions = repetitions[0].sub(/\**/, '') if repetitions != nil

    go_up = token.count('^')

    same_level = token.match(/\+/)
    same_level = true if same_level != nil

    do_descent = token.match(/\>/)
    do_descent = true if do_descent != nil

    puts('TOKEN: ' + token + ' - ' +
         name.to_s + ' - ' +
         repetitions.to_s + ' - ' +
         go_up.to_s + ' - ' +
         same_level.to_s + ' - ' +
         do_descent.to_s)
  end
end

s = 'o.object>o>a.array>s*3+n*2^t.true+f+n'
puts(s)
Jemmet.parse(s)
