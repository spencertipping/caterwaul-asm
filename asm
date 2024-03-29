#!/usr/bin/perl
# 99aeabc9ec7fe80b1b39f5e53dc7e49e      <- self-modifying Perl magic

# This is a self-modifying Perl file. I'm sorry you're viewing the source (it's
# really gnarly). If you're curious what it's made of, I recommend reading
# http://github.com/spencertipping/writing-self-modifying-perl.
#
# If you got one of these from someone and don't know what to do with it, send
# it to spencer@spencertipping.com and I'll see if I can figure out what it
# does.

# For the benefit of HTML viewers (this is hack):
# <div id='cover' style='position: absolute; left: 0; top: 0; width: 10000px; height: 10000px; background: white'></div>

$|++;

my %data;
my %transient;
my %externalized_functions;
my %datatypes;

my %locations;          # Maps eval-numbers to attribute names

my $global_data = join '', <DATA>;

sub meta::define_form {
  my ($namespace, $delegate) = @_;
  $datatypes{$namespace} = $delegate;
  *{"meta::${namespace}::implementation"} = $delegate;
  *{"meta::$namespace"} = sub {
    my ($name, $value, %options) = @_;
    chomp $value;
    $data{"${namespace}::$name"} = $value unless $options{no_binding};
    &$delegate($name, $value) unless $options{no_delegate}}}

sub meta::eval_in {
  my ($what, $where) = @_;

  # Obtain next eval-number and alias it to the designated location
  @locations{eval('__FILE__') =~ /\(eval (\d+)\)/} = ($where);

  my $result = eval $what;
  $@ =~ s/\(eval \d+\)/$where/ if $@;
  warn $@ if $@;
  $result}

meta::define_form 'meta', sub {
  my ($name, $value) = @_;
  meta::eval_in($value, "meta::$name")};

meta::meta('configure', <<'__');
# A function to configure transients. Transients can be used to store any number of
# different things, but one of the more common usages is type descriptors.

sub meta::configure {
  my ($datatype, %options) = @_;
  $transient{$_}{$datatype} = $options{$_} for keys %options;
}
__
meta::meta('externalize', <<'__');
# Function externalization. Data types should call this method when defining a function
# that has an external interface.

sub meta::externalize {
  my ($name, $attribute, $implementation) = @_;
  my $escaped = $name;
  $escaped =~ s/[^A-Za-z0-9:]/_/go;
  $externalized_functions{$name} = $externalized_functions{$escaped} = $attribute;
  *{"::$name"} = *{"::$escaped"} = $implementation || $attribute;
}

__
meta::meta('functor::editable', <<'__');
# An editable type. This creates a type whose default action is to open an editor
# on whichever value is mentioned. This can be changed using different flags.

sub meta::functor::editable {
  my ($typename, %options) = @_;

  meta::configure $typename, %options;
  meta::define_form $typename, sub {
    my ($name, $value) = @_;

    $options{on_bind} && &{$options{on_bind}}($name, $value);

    meta::externalize $options{prefix} . $name, "${typename}::$name", sub {
      my $attribute             = "${typename}::$name";
      my ($command, @new_value) = @_;

      return &{$options{default}}(retrieve($attribute)) if ref $options{default} eq 'CODE' and not defined $command;
      return edit($attribute) if $command eq 'edit' or $options{default} eq 'edit' and not defined $command;
      return associate($attribute, @new_value ? join(' ', @new_value) : join('', <STDIN>)) if $command eq '=' or $command eq 'import' or $options{default} eq 'import' and not defined $command;
      return retrieve($attribute)}}}
__
meta::meta('type::alias', <<'__');
meta::configure 'alias', inherit => 0;
meta::define_form 'alias', sub {
  my ($name, $value) = @_;
  meta::externalize $name, "alias::$name", sub {
    # Can't pre-tokenize because shell::tokenize doesn't exist until the library::
    # namespace has been evaluated (which will be after alias::).
    shell::run(shell::tokenize($value), shell::tokenize(@_));
  };
};
__
meta::meta('type::bootstrap', <<'__');
# Bootstrap attributes don't get executed. The reason for this is that because
# they are serialized directly into the header of the file (and later duplicated
# as regular data attributes), they will have already been executed when the
# file is loaded.

meta::configure 'bootstrap', extension => '.pl', inherit => 1;
meta::define_form 'bootstrap', sub {};
__
meta::meta('type::cache', <<'__');
meta::configure 'cache', inherit => 0;
meta::define_form 'cache', \&meta::bootstrap::implementation;
__
meta::meta('type::data', 'meta::functor::editable \'data\', extension => \'\', inherit => 0, default => \'cat\';');
meta::meta('type::function', <<'__');
meta::configure 'function', extension => '.pl', inherit => 1;
meta::define_form 'function', sub {
  my ($name, $value) = @_;
  meta::externalize $name, "function::$name", meta::eval_in("sub {\n$value\n}", "function::$name");
};
__
meta::meta('type::hook', <<'__');
meta::configure 'hook', extension => '.pl', inherit => 0;
meta::define_form 'hook', sub {
  my ($name, $value) = @_;
  *{"hook::$name"} = meta::eval_in("sub {\n$value\n}", "hook::$name");
};
__
meta::meta('type::inc', <<'__');
meta::configure 'inc', inherit => 1, extension => '.pl';
meta::define_form 'inc', sub {
  use File::Path 'mkpath';
  use File::Basename qw/basename dirname/;

  my ($name, $value) = @_;
  my $tmpdir   = basename($0) . '-' . $$;
  my $filename = "/tmp/$tmpdir/$name";

  push @INC, "/tmp/$tmpdir" unless grep /^\/tmp\/$tmpdir$/, @INC;

  mkpath(dirname($filename));
  unless (-e $filename) {
    open my $fh, '>', $filename;
    print $fh $value;
    close $fh;
  }
};
__
meta::meta('type::indicator', <<'__');
# Shell indicator function. The output of each of these is automatically
# appended to the shell prompt.

meta::configure 'indicator', inherit => 1, extension => '.pl';
meta::define_form 'indicator', sub {
  my ($name, $value) = @_;
  *{"indicator::$name"} = meta::eval_in("sub {\n$value\n}", "indicator::$name");
};
__
meta::meta('type::internal_function', <<'__');
meta::configure 'internal_function', extension => '.pl', inherit => 1;
meta::define_form 'internal_function', sub {
  my ($name, $value) = @_;
  *{$name} = meta::eval_in("sub {\n$value\n}", "internal_function::$name");
};
__
meta::meta('type::js', <<'__');
meta::functor::editable 'js', extension => '.js', inherit => 1;

__
meta::meta('type::library', <<'__');
meta::configure 'library', extension => '.pl', inherit => 1;
meta::define_form 'library', sub {
  my ($name, $value) = @_;
  meta::eval_in($value, "library::$name");
};
__
meta::meta('type::message_color', <<'__');
meta::configure 'message_color', extension => '', inherit => 1;
meta::define_form 'message_color', sub {
  my ($name, $value) = @_;
  terminal::color($name, $value);
};
__
meta::meta('type::meta', <<'__');
# This doesn't define a new type. It customizes the existing 'meta' type
# defined in bootstrap::initialization. Note that horrible things will
# happen if you redefine it using the editable functor.

meta::configure 'meta', extension => '.pl', inherit => 1;
__
meta::meta('type::parent', <<'__');
meta::define_form 'parent', \&meta::bootstrap::implementation;
meta::configure 'parent', extension => '', inherit => 1;
__
meta::meta('type::retriever', <<'__');
meta::configure 'retriever', extension => '.pl', inherit => 1;
meta::define_form 'retriever', sub {
  my ($name, $value) = @_;
  $transient{retrievers}{$name} = meta::eval_in("sub {\n$value\n}", "retriever::$name");
};
__
meta::meta('type::sdoc', <<'__');
# A meta-type for other types. So retrieve('js::main') will work if you have
# the attribute 'sdoc::js::main'. The filename will be main.js.sdoc.

meta::functor::editable 'sdoc', inherit => 1, extension => sub {
  extension_for(attribute($_[0])) . '.sdoc';
};
__
meta::meta('type::slibrary', <<'__');
meta::configure 'slibrary', extension => '.pl.sdoc', inherit => 1;
meta::define_form 'slibrary', sub {
  my ($name, $value) = @_;
  meta::eval_in(sdoc("slibrary::$name"), "slibrary::$name");
};

__
meta::meta('type::state', <<'__');
# Allows temporary or long-term storage of states. Nothing particularly insightful
# is done about compression, so storing alternative states will cause a large
# increase in size. Also, states don't contain other states -- otherwise the size
# increase would be exponential.

# States are created with the save-state function.

meta::configure 'state', inherit => 0, extension => '.pl';
meta::define_form 'state', \&meta::bootstrap::implementation;
__
meta::meta('type::template', <<'__');
meta::configure 'template', extension => '.pl', inherit => 1;
meta::define_form 'template', sub {
  my ($name, $value) = @_;
  meta::externalize "template::$name", "template::$name", meta::eval_in("sub {\n$value\n}", "template::$name");
};
__
meta::meta('type::waul', <<'__');
meta::functor::editable 'waul', inherit => 1, extension => '.waul', default => 'edit';

__
meta::alias('e', 'edit sdoc::waul::asm-x64');
meta::bootstrap('html', <<'__');
<html>
  <head>
  <meta http-equiv='content-type' content='text/html; charset=UTF-8' />
  <link rel='stylesheet' href='http://spencertipping.com/perl-objects/web/style.css'/>

  <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.5.2/jquery.min.js'></script>
  <script src='http://spencertipping.com/caterwaul/caterwaul.all.min.js'></script>
  <script src='http://spencertipping.com/montenegro/montenegro.client.js'></script>
  <script src='http://spencertipping.com/perl-objects/web/attribute-parser.js'></script>
  <script src='http://spencertipping.com/perl-objects/web/interface.js'></script>
  </head>
  <body></body>
</html>

__
meta::bootstrap('initialization', <<'__');
#!/usr/bin/perl
# 99aeabc9ec7fe80b1b39f5e53dc7e49e      <- self-modifying Perl magic

# This is a self-modifying Perl file. I'm sorry you're viewing the source (it's
# really gnarly). If you're curious what it's made of, I recommend reading
# http://github.com/spencertipping/writing-self-modifying-perl.
#
# If you got one of these from someone and don't know what to do with it, send
# it to spencer@spencertipping.com and I'll see if I can figure out what it
# does.

# For the benefit of HTML viewers (this is hack):
# <div id='cover' style='position: absolute; left: 0; top: 0; width: 10000px; height: 10000px; background: white'></div>

$|++;

my %data;
my %transient;
my %externalized_functions;
my %datatypes;

my %locations;          # Maps eval-numbers to attribute names

my $global_data = join '', <DATA>;

sub meta::define_form {
  my ($namespace, $delegate) = @_;
  $datatypes{$namespace} = $delegate;
  *{"meta::${namespace}::implementation"} = $delegate;
  *{"meta::$namespace"} = sub {
    my ($name, $value, %options) = @_;
    chomp $value;
    $data{"${namespace}::$name"} = $value unless $options{no_binding};
    &$delegate($name, $value) unless $options{no_delegate}}}

sub meta::eval_in {
  my ($what, $where) = @_;

  # Obtain next eval-number and alias it to the designated location
  @locations{eval('__FILE__') =~ /\(eval (\d+)\)/} = ($where);

  my $result = eval $what;
  $@ =~ s/\(eval \d+\)/$where/ if $@;
  warn $@ if $@;
  $result}

meta::define_form 'meta', sub {
  my ($name, $value) = @_;
  meta::eval_in($value, "meta::$name")};

__
meta::bootstrap('perldoc', <<'__');
=head1 Self-modifying Perl script

=head2 Original implementation by Spencer Tipping L<http://spencertipping.com>

The prototype for this script is licensed under the terms of the MIT source code license.
However, this script in particular may be under different licensing terms. To find out how
this script is licensed, please contact whoever sent it to you. Alternatively, you may
run it with the 'license' argument if they have specified a license that way.

You should not edit this file directly. For information about how it was constructed, go
to L<http://spencertipping.com/writing-self-modifying-perl>. For quick usage guidelines,
run this script with the 'usage' argument.

=cut

__
meta::cache('parent-identification', <<'__');
/home/spencertipping/bin/object 99aeabc9ec7fe80b1b39f5e53dc7e49e
/home/spencertipping/bin/waul-object 4e04fdb8e560f4dd2ca4880b91a8e2ea
/home/spencertipping/conjectures/perl-objects/js 246bc56c88e8e8daae3737dbb16a2a2c
/home/spencertipping/conjectures/perl-objects/sdoc a1e8480e579614c01dabeecf0f963bcc
object 99aeabc9ec7fe80b1b39f5e53dc7e49e
preprocessor 70dae4b46eb4e06798ec6f38d17d4c7b
__
meta::data('author', 'Spencer Tipping');
meta::data('default-action', 'shell');
meta::data('license', <<'__');
MIT License
Copyright (c) 2010 Spencer Tipping

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
__
meta::function('ad', <<'__');
my ($options, @paths) = separate_options(@_);
@{$transient{path}} = () if $$options{-c};
return @{$transient{path}} = () unless @paths;
push @{$transient{path}}, @paths;

__
meta::function('alias', <<'__');
my ($name, @stuff) = @_;
@_ ? @stuff ? around_hook('alias', @_, sub {associate("alias::$name", join(' ', @stuff), execute => 1)})
            : retrieve("alias::$name") // "Undefined alias $name"
   : table_display([select_keys('--namespace' => 'alias')], [map retrieve($_), select_keys('--namespace' => 'alias')]);

__
meta::function('cat', 'join "\\n", retrieve(@_);');
meta::function('cc', <<'__');
# Stashes a quick one-line continuation. (Used to remind me what I was doing.)
@_ ? associate('data::current-continuation', hook('set-cc', join(' ', @_))) : retrieve('data::current-continuation');
__
meta::function('ccc', 'rm(\'data::current-continuation\');');
meta::function('child', <<'__');
around_hook('child', @_, sub {
  my ($child_name) = @_;
  clone($child_name);
  enable();
  qx($child_name update-from $0 -n);
  disable()});
__
meta::function('clone', <<'__');
for (grep length, @_) {
  around_hook('clone', $_, sub {
    hypothetically(sub {
      rm('data::permanent-identity');
      file::write($_, serialize(), noclobber => 1);
      chmod(0700, $_)})})}
__
meta::function('cp', <<'__');
my $from = shift @_;
my $value = retrieve($from);
associate($_, $value) for @_;
__
meta::function('create', <<'__');
my ($name, $value) = @_;
around_hook('create', $name, $value, sub {
  return edit($name) if exists $data{$name};
  associate($name, defined $value ? $value : '');
  edit($name) unless defined $value});
__
meta::function('current-state', 'serialize(\'-pS\');');
meta::function('disable', 'hook(\'disable\', chmod_self(sub {$_[0] & 0666}));');
meta::function('edit', <<'__');
my ($name, %options) = @_;
my $extension = extension_for($name);

die "$name is virtual or does not exist" unless exists $data{$name};
die "$name is inherited; use 'edit $name -f' to edit anyway" unless is($name, '-u') || is($name, '-d') || exists $options{'-f'};

around_hook('edit', @_, sub {
  associate($name, invoke_editor_on($data{$name} // '', %options, attribute => $name, extension => $extension), execute => 1)});

save() unless $data{'data::edit::no-save'};
'';

__
meta::function('edit-self', <<'__');
$global_data = invoke_editor_on($global_data);
save();

__
meta::function('enable', 'hook(\'enable\', chmod_self(sub {$_[0] | $_[0] >> 2}));');
meta::function('export', <<'__');
# Exports data into a text file.
#   export attr1 attr2 attr3 ... file.txt
my $name = pop @_;
@_ or die 'Expected filename';
file::write($name, join "\n", retrieve(@_));
__
meta::function('extern', '&{$_[0]}(retrieve(@_[1 .. $#_]));');
meta::function('grep', <<'__');
# Looks through attributes for a pattern. Usage is grep pattern [options], where
# [options] is the format as provided to select_keys.

my ($pattern, @args)     = @_;
my ($options, @criteria) = separate_options(@args);
my @attributes           = select_keys(%$options, '--criteria' => join('|', @criteria));

$pattern = qr/$pattern/;

my @m_attributes;
my @m_line_numbers;
my @m_lines;

for my $k (@attributes) {
  next unless length $k;
  my @lines = split /\n/, retrieve($k);
  for (0 .. $#lines) {
    next unless $lines[$_] =~ $pattern;
    push @m_attributes,   $k;
    push @m_line_numbers, $_ + 1;
    push @m_lines,        '' . ($lines[$_] // '')}}

unless ($$options{'-C'}) {
  s/($pattern)/\033[1;31m\1\033[0;0m/g for @m_lines;
  s/^/\033[1;34m/o for @m_attributes;
  s/^/\033[1;32m/o && s/$/\033[0;0m/o for @m_line_numbers}

table_display([@m_attributes], [@m_line_numbers], [@m_lines]);
__
meta::function('hash', 'fast_hash(@_);');
meta::function('hook', <<'__');
my ($hook, @args) = @_;
$transient{active_hooks}{$hook} = 1;
dangerous('', sub {&$_(@args)}) for grep /^hook::${hook}::/, sort keys %data;
@args;
__
meta::function('hooks', 'join "\\n", sort keys %{$transient{active_hooks}};');
meta::function('identity', 'retrieve(\'data::permanent-identity\') || associate(\'data::permanent-identity\', fast_hash(rand() . name() . serialize()));');
meta::function('import', <<'__');
my $name = pop @_;
associate($name, @_ ? join('', map(file::read($_), @_)) : join('', <STDIN>)); 
__
meta::function('initial-state', '$transient{initial};');
meta::function('is', <<'__');
my ($attribute, @criteria) = @_;
my ($options, @stuff) = separate_options(@criteria);
exists $data{$attribute} and attribute_is($attribute, %$options);

__
meta::function('load-state', <<'__');
around_hook('load-state', @_, sub {
  my ($state_name) = @_;
  my $state = retrieve("state::$state_name");

  terminal::state('saving current state into _...');
  save_state('_');

  delete $data{$_} for grep ! /^state::/, keys %data;
  %externalized_functions = ();

  terminal::state("restoring state $state_name...");
  meta::eval_in($state, "state::$state_name");
  terminal::error(hook('load-state-failed', $@)) if $@;
  reload();
  verify()});

__
meta::function('lock', 'hook(\'lock\', chmod_self(sub {$_[0] & 0555}));');
meta::function('ls', <<'__');
my ($options, @criteria) = separate_options(@_);
my ($external, $shadows, $sizes, $flags, $long, $hashes, $parent_hashes) = @$options{qw(-e -s -z -f -l -h -p)};
$sizes = $flags = $hashes = $parent_hashes = 1 if $long;

return table_display([grep ! exists $data{$externalized_functions{$_}}, sort keys %externalized_functions]) if $shadows;

my $criteria    = join('|', @criteria);
my @definitions = select_keys('--criteria' => $criteria, '--path' => $transient{path}, %$options);

my %inverses  = map {$externalized_functions{$_} => $_} keys %externalized_functions;
my @externals = map $inverses{$_}, grep length, @definitions;
my @internals = grep length $inverses{$_}, @definitions;
my @sizes     = map sprintf('%6d %6d', length(serialize_single($_)), length(retrieve($_))), @{$external ? \@internals : \@definitions} if $sizes;

my @flags     = map {my $k = $_; join '', map(is($k, "-$_") ? $_ : '-', qw(d i m u))} @definitions if $flags;
my @hashes    = map fast_hash(retrieve($_)), @definitions if $hashes;

my %inherited     = parent_attributes(grep /^parent::/o, keys %data) if $parent_hashes;
my @parent_hashes = map $inherited{$_} || '-', @definitions if $parent_hashes;

join "\n", map strip($_), split /\n/, table_display($external ? [grep length, @externals] : [@definitions],
                                                    $sizes ? ([@sizes]) : (), $flags ? ([@flags]) : (), $hashes ? ([@hashes]) : (), $parent_hashes ? ([@parent_hashes]) : ());

__
meta::function('minify-yui', <<'__');
# Minify using YUI compressor
my ($options, @filenames) = separate_options(@_);
my $nomunge   = $$options{-m} ? '' : '--nomunge';
my $linebreak = $$options{-B} ? '' : '--line-break 160';

for my $filename (@filenames) {
  my $minified = $filename;
  $minified =~ s/\.js$/.min.js/;

  terminal::info("minifying $filename");
  file::write($minified, join '', qx(yuicompressor $nomunge $linebreak "$filename"));
}

__
meta::function('mv', <<'__');
my ($from, $to) = @_;
die "'$from' does not exist" unless exists $data{$from};
associate($to, retrieve($from), execute => 1);
rm($from);

__
meta::function('name', <<'__');
my $name = $0;
$name =~ s/^.*\///;
$name;
__
meta::function('parents', 'join "\\n", grep s/^parent:://o, sort keys %data;');
meta::function('perl', <<'__');
my @result = eval(join ' ', @_);
$@ ? terminal::error($@) : wantarray ? @result : $result[0];

__
meta::function('preprocess', <<'__');
# Implements a simple preprocessing language.
# Syntax follows two forms. One is the 'line form', which gives you a way to specify arguments inline
# but not spanning multiple lines. The other is 'block form', which gives you access to both one-line
# arguments and a block of lines. The line parameters are passed in verbatim, and the block is
# indentation-adjusted and then passed in as a second parameter. (Indentation is adjusted to align
# with the name of the command.)
#
# Here are the forms:
#
# - line arguments to function
#
# - block line arguments << eof
#   block contents
#   block contents
#   ...
# - eof

my ($string, %options) = @_;
my $expansions         = 0;
my $old_string         = '';
my $limit              = $options{expansion_limit} || 100;
my @pieces             = ();

sub adjust_spaces {
  my ($spaces, $string) = @_;
  $string =~ s/^$spaces  //mg;
  chomp $string;
  $string;
}

while ($old_string ne $string and $expansions++ < $limit) {
  $old_string = $string;

  while ((my @pieces = split  /(^(\h*)-\h \S+ \h* \V* <<\h*(\w+)$ \n .*?  ^\2-\h\3$)/xms, $string) > 1 and $expansions++ < $limit) {
    $pieces[1 + ($_ << 2)] =~ /^ (\h*)-\h(\S+)\h*(\V*)<<\h*(\w+)$ \n(.*?) ^\1-\h\4 $/xms && $externalized_functions{"template::$2"} and
      $pieces[1 + ($_ << 2)] = &{"template::$2"}($3, adjust_spaces($1, $5))
      for 0 .. $#pieces / 4;

    @pieces[2 + ($_ << 2), 3 + ($_ << 2)] = '' for 0 .. $#pieces / 4;
    $string = join '', @pieces;
  }

  if ((my @pieces = split     /^(\h*-\h \S+ \h* .*)$/xom, $string) > 1) {
    $pieces[1 + ($_ << 1)] =~ /^ \h*-\h(\S+)\h*(.*)$/xom && $externalized_functions{"template::$1"} and
      $pieces[1 + ($_ << 1)] = &{"template::$1"}($2)
      for 0 .. $#pieces >> 1;

    $string = join '', @pieces;
  }
}

$string;
__
meta::function('rd', <<'__');
if (@_) {my $pattern = join '|', @_;
         @{$transient{path}} = grep $_ !~ /^$pattern$/, @{$transient{path}}}
else    {pop @{$transient{path}}}

__
meta::function('reload', 'around_hook(\'reload\', sub {execute($_) for grep ! /^bootstrap::/, keys %data});');
meta::function('render', <<'__');
file::write('README.md', retrieve('markdown::readme'));

file::write('src/asm-x64.md',   retrieve('markdown::waul::asm-x64'), mkpath => 1);
file::write('src/asm-x64.waul', retrieve('waul::asm-x64'),           mkpath => 1);

terminal::info('waul-compiling');
sh('waul -e deps/bitwise.js src/asm-x64.waul && mv src/asm-x64.js .');

__
meta::function('rm', <<'__');
around_hook('rm', @_, sub {
  exists $data{$_} or terminal::warning("$_ does not exist") for @_;
  delete @data{@_}});
__
meta::function('rmparent', <<'__');
# Removes one or more parents.
my ($options, @parents) = separate_options(@_);
my $clobber_divergent = $$options{'-D'} || $$options{'--clobber-divergent'};

my %parents = map {$_ => 1} @parents;
my @other_parents = grep !$parents{$_}, grep s/^parent:://, select_keys('--namespace' => 'parent');
my %kept_by_another_parent;

$kept_by_another_parent{$_} = 1 for grep s/^(\S+)\s.*$/\1/, split /\n/o, cat(@other_parents);

for my $parent (@parents) {
  my $keep_parent_around = 0;

  for my $line (split /\n/, retrieve("parent::$parent")) {
    my ($name, $hash) = split /\s+/, $line;
    next unless exists $data{$name};

    my $local_hash = fast_hash(retrieve($name));
    if ($clobber_divergent or $hash eq $local_hash or ! defined $hash) {rm($name) unless $kept_by_another_parent{$name}}
    else {terminal::info("local attribute $name exists and is divergent; use rmparent -D $parent to delete it");
          $keep_parent_around = 1}}

  $keep_parent_around ? terminal::info("not deleting parent::$parent so that you can run", "rmparent -D $parent if you want to nuke divergent attributes too")
                      : rm("parent::$parent")}

__
meta::function('save', 'around_hook(\'save\', sub {dangerous(\'\', sub {file::write($0, serialize()); $transient{initial} = state()}) if verify()});');
meta::function('save-state', <<'__');
# Creates a named copy of the current state and stores it.
my ($state_name) = @_;
around_hook('save-state', $state_name, sub {
  associate("state::$state_name", current_state(), execute => 1)});

__
meta::function('sdoc', <<'__');
# Applies SDoc processing to a file or attribute. Takes the file or attribute
# name as the first argument and returns the processed text.

my %comments_for_extension = 
  qw|c     /*,*/  cpp   //    cc   //    h    //    java //  py  #    rb   #    pl  #   pm   #         ml   (*,*)  js  //
     hs    --     sh    #     lisp ;;;   lsp  ;;;   s    #   scm ;;;  sc   ;;;  as  //  html <!--,-->  mli  (*,*)  cs  //
     vim   "      elisp ;     bas  '     ada  --    asm  ;   awk #    bc   #    boo #   tex  %         fss  (*,*)  erl %
     scala //     hx    //    io   //    j    NB.   lua  --  n   //   m    %    php //  sql  --        pov  //     pro %
     r     #      self  ","   tcl  #     texi @c    tk   #   csh #    vala //   vbs '   v    /*,*/     vhdl --     ss  ;;;
     haml  -#     sass  /*,*/ scss /*,*/ css  /*,*/ fig  /   waul #|;

# No extension suggests a shebang line, which generally requires # to denote a comment.
$comments_for_extension{''} = '#';

my $generated_string = 'Generated by SDoc';

sub is_code    {map /^\s*[^A-Z\|\s]/o, @_}
sub is_blank   {map /^\n/o, @_}
sub comment    {my ($text, $s, $e) = @_; join "\n", map("$s $_$e", split /\n/, $text)}

sub paragraphs {map split(/((?:\n\h*){2,})/, $_), @_}

my ($filename, $specified_extension) = @_;

# Two possibilities here. One is that the filename is an attribute, in which case
# we want to look up the extension in the transients table. The other is that
# it's a real filename.
my ($extension)       = $specified_extension || ($filename =~ /\.sdoc$/io ? $filename =~ /\.(\w+)\.sdoc$/igo : $filename =~ /\.(\w+)$/igo);
my ($other_extension) = extension_for($filename);
$other_extension =~ s/\.sdoc$//io;
$other_extension =~ s/^\.//o;

my ($start, $end) = split /,/o, $comments_for_extension{lc($other_extension || $extension)} // $comments_for_extension{''} // '#';

join '', map(is_code($_) || is_blank($_) ? ($_ =~ /^\s*c\n(.*)$/so ? $1 : $_) : comment($_, $start, $end), paragraphs retrieve($filename)),
         "\n$start $generated_string $end\n";

__
meta::function('sdoc-html', <<'__');
# Converts SDoc to logically-structured HTML. Sections end up being nested,
# and code sections and examples are marked as such. For instance, here is some
# sample output:

# <div class='section level1'>
#   <h1 class='title'>Foo</h1>
#   <p>This is a paragraph...</p>
#   <p>This is another paragraph...</p>
#   <pre class='code'>int main () {return 0;}</pre>
#   <pre class='quoted'>int main () {return 0} // Won't compile</pre>
#   <div class='section level2'>
#     <h2 class='title'>Bar</h2>
#     ...
#   </div>
# </div>

# It is generally good about escaping things that would interfere with HTML,
# but within text paragraphs it lets you write literal HTML. The heuristic is
# that known tags that are reasonably well-formed are allowed, but unknown ones
# are escaped.

my ($attribute)   = @_;
my @paragraphs    = split /\n(?:\s*\n)+/, retrieve($attribute);

my $known_tags    = join '|', qw[html head body meta script style link title div a span input button textarea option select form label iframe blockquote code caption
                                 table tbody tr td th thead tfoot img h1 h2 h3 h4 h5 h6 li ol ul noscript p pre samp sub sup var canvas audio video strong em];
my $section_level = 0;
my @markup;

my $indent        = sub {'  ' x ($_[0] || $section_level)};
my $unindent      = sub {my $spaces = '  ' x ($section_level - 1); s/^$spaces//gm};

my $escape_all    = sub {s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g};
my $escape_some   = sub {s/&/&amp;/g; s/<(?!\/|($known_tags)[^>]*>.*<\/\1>)/&lt;/gs};

my $code          = sub {&$escape_all(); &$unindent(); s/^c\n//;                   push @markup, &$indent() . "<pre class='code'>$_</pre>"};
my $quoted        = sub {&$escape_all(); &$unindent(); s/^\|(\s?)/ \1/; s/^  //mg; push @markup, &$indent() . "<pre class='quoted'>$_</pre>"};

my $paragraph     = sub {&$escape_some(); push @markup, &$indent() . "<p>$_</p>"};

my $section       = sub {my $h = $_[0] > 6 ? 6 : $_[0]; push @markup, &$indent($_[0] - 1) . "<div class='section level$_[0]'>", &$indent($_[0]) . "<h$h>$2</h$h>"};
my $close_section = sub {push @markup, &$indent($_[0]) . "</div>"};

my $title = sub {
  my $indentation = (length($1) >> 1) + 1;
  &$close_section($section_level) while $section_level-- >= $indentation;
  &$section($indentation);
  $section_level = $indentation;
};

for (@paragraphs) {
  &$code(),   next unless /^\h*[A-Z|]/;
  &$quoted(), next if     /^\h*\|/;

  &$title(), s/^.*\n// if /^(\s*)(\S.*)\.\n([^\n]+)/ and length("$1$2") < 60 and length("$1$2") - 10 < length($3);
  &$paragraph();
}

&$close_section($section_level) while $section_level--;

join "\n", @markup;

__
meta::function('sdoc-markdown', <<'__');
# Renders a chunk of SDoc as Markdown. This involves converting quoted and
# unquoted code and section headings, but not numbered lists.

my ($attribute)   = @_;
my @paragraphs    = split /\n(?:\s*\n)+/, retrieve($attribute);

my $section_level = 0;
my @markup;

my $indent        = sub {'  ' x ($_[0] || $section_level)};
my $unindent      = sub {my $spaces = '  ' x ($section_level - 1); s/^$spaces//gm; $_};

my $code          = sub {&$unindent(); s/^c\n//;                   push @markup, join("\n", map &$indent(2) . $_, split /\n/)};
my $quoted        = sub {&$unindent(); s/^\|(\s?)/ \1/; s/^  //mg; push @markup, join("\n", map &$indent(2) . $_, split /\n/)};

my $heading       = sub {'#' x $_[0]};
my $section       = sub {&$unindent(); push @markup, &$heading($_[0]) . ' ' . $2};

my $title = sub {
  my $indentation = (length($1) >> 1) + 1;
  &$section($indentation);
  $section_level = $indentation;
};

for (@paragraphs) {
  &$code(),   next unless /^\h*[A-Z|]/;
  &$quoted(), next if     /^\h*\|/;

  &$title(), s/^.*\n// if /^(\s*)(\S.*)\.\n([^\n]+)/ and length("$1$2") < 60 and length("$1$2") - 10 < length($3);
  push @markup, join "\n", map &$unindent(), split /\n/;
}

join "\n\n", @markup;

__
meta::function('sdocp', <<'__');
# Renders an attribute as SDocP. This logic was taken directly from the sdoc script.
my $attribute = retrieve($_[0]);
sub escape {my @results = map {s/\\/\\\\/go; s/\n/\\n/go; s/'/\\'/go; $_} @_; wantarray ? @results : $results[0]}
"sdocp('" . escape($_[0]) . "', '" . escape($attribute) . "');";
__
meta::function('serialize', <<'__');
my ($options, @criteria) = separate_options(@_);
my $partial     = $$options{'-p'};
my $criteria    = join '|', @criteria;
my @attributes  = map serialize_single($_), select_keys(%$options, '-m' => 1, '-V' => 1, '--criteria' => $criteria), select_keys(%$options, '-M' => 1, '-V' => 1, '--criteria' => $criteria);
my @final_array = @{$partial ? \@attributes : [retrieve('bootstrap::initialization'), @attributes, 'internal::main();', '', '__DATA__', $global_data]};
join "\n", @final_array;

__
meta::function('serialize-single', <<'__');
# Serializes a single attribute and optimizes for content.

my $name          = $_[0] || $_;
my $contents      = $data{$name};
my $meta_function = 'meta::' . namespace($name);
my $invocation    = attribute($name);
my $escaped       = $contents;
$escaped =~ s/\\/\\\\/go;
$escaped =~ s/'/\\'/go;

return "$meta_function('$invocation', '$escaped');" unless $escaped =~ /\v/;

my $delimiter = '__' . fast_hash($contents);
my $chars     = 2;

++$chars until $chars >= length($delimiter) || index("\n$contents", "\n" . substr($delimiter, 0, $chars)) == -1;
$delimiter = substr($delimiter, 0, $chars);

"$meta_function('$invocation', <<'$delimiter');\n$contents\n$delimiter";

__
meta::function('sh', 'system(@_);');
meta::function('shb', <<'__');
# Backgrounded shell job.
exec(@_) unless fork;

__
meta::function('shell', <<'__');
my ($options, @arguments) = separate_options(@_);
$transient{repl_prefix} = $$options{'--repl-prefix'};

terminal::cc(retrieve('data::current-continuation')) if length $data{'data::current-continuation'};
around_hook('shell', sub {shell::repl(%$options)});

__
meta::function('size', <<'__');
my $size = 0;
$size += length $data{$_} for keys %data;
sprintf "   full logical  unique    self\n% 7d % 7d % 7d % 7d", length(serialize()), $size, length(serialize('-up')), length $global_data;

__
meta::function('snapshot', <<'__');
my ($name) = @_;
file::write(my $finalname = temporary_name($name), serialize(), noclobber => 1);
chmod 0700, $finalname;
hook('snapshot', $finalname);
__
meta::function('state', <<'__');
my @keys = grep !is($_, '-v'), sort keys %data;
my $hash = fast_hash(fast_hash(scalar @keys) . join '|', @keys);
$hash = fast_hash("$data{$_}|$hash") for @keys;
$hash;

__
meta::function('touch', 'associate($_, \'\') for @_;');
meta::function('unlock', 'hook(\'unlock\', chmod_self(sub {$_[0] | 0200}));');
meta::function('update', <<'__');
update_from(@_, grep s/^parent:://o, sort keys %data);

__
meta::function('update-from', <<'__');
# Upgrade all attributes that aren't customized. Customization is defined when the data type is created,
# and we determine it here by checking for $transient{inherit}{$type}.

# Note that this assumes you trust the remote script. If you don't, then you shouldn't update from it.

around_hook('update-from-invocation', separate_options(@_), sub {
  my ($options, @targets) = @_;
  my %parent_id_cache = cache('parent-identification');
  my %already_seen;

  @targets or return;

  my @known_targets     = grep s/^parent:://, parent_ordering(map "parent::$_", grep exists $data{"parent::$_"}, @targets);
  my @unknown_targets   = grep ! exists $data{"parent::$_"}, @targets;
  @targets = (@known_targets, @unknown_targets);

  my $save_state        = $$options{'-s'} || $$options{'--save'};
  my $no_parents        = $$options{'-P'} || $$options{'--no-parent'} || $$options{'--no-parents'};
  my $force             = $$options{'-f'} || $$options{'--force'};
  my $clobber_divergent = $$options{'-D'} || $$options{'--clobber-divergent'};

  save_state('before-update');

  for my $target (@targets) {
    dangerous("updating from $target", sub {
    around_hook('update-from', $target, sub {
      my $identity = $parent_id_cache{$target} ||= join '', qx($target identity);
      next if $already_seen{$identity};
      $already_seen{$identity} = 1;

      my $attributes = join '', qx($target ls -ahiu);
      my %divergent;
      die "skipping unreachable $target" unless $attributes;

      for my $to_rm (split /\n/, retrieve("parent::$target")) {
        my ($name, $hash) = split(/\s+/, $to_rm);
        next unless exists $data{$name};

        my $local_hash = fast_hash(retrieve($name));
        if ($clobber_divergent or $hash eq $local_hash or ! defined $hash) {rm($name)}
        else {terminal::info("preserving local version of divergent attribute $name (use update -D to clobber it)");
              $divergent{$name} = retrieve($name)}}

      associate("parent::$target", $attributes) unless $no_parents;

      dangerous('', sub {eval qx($target serialize -ipmu)});
      dangerous('', sub {eval qx($target serialize -ipMu)});

      map associate($_, $divergent{$_}), keys %divergent unless $clobber_divergent;

      reload()})})}

  cache('parent-identification', %parent_id_cache);

  if (verify()) {hook('update-from-succeeded', $options, @targets);
                 terminal::info("Successfully updated. Run 'load-state before-update' to undo this change.") if $save_state;
                 rm('state::before-update') unless $save_state}
  elsif ($force) {hook('update-from-failed', $options, @targets);
                  terminal::warning('Failed to verify: at this point your object will not save properly, though backup copies will be created.',
                                    'Run "load-state before-update" to undo the update and return to a working state.')}
  else {hook('update-from-failed', $options, @targets);
        terminal::error('Verification failed after the upgrade was complete.');
        terminal::info("$0 has been reverted to its pre-upgrade state.", "If you want to upgrade and keep the failure state, then run 'update-from $target --force'.");
        load_state('before-update');
        rm('state::before-update')}});

__
meta::function('usage', '"Usage: $0 action [arguments]\\nUnique actions (run \'$0 ls\' to see all actions):" . ls(\'-u\');');
meta::function('verify', <<'__');
file::write(my $other = $transient{temporary_filename} = temporary_name(), my $serialized_data = serialize());
chomp(my $observed = join '', qx|perl '$other' state|);

unlink $other if my $result = $observed eq (my $state = state());
terminal::error("Verification failed; expected $state but got $observed from $other") unless $result;
hook('after-verify', $result, observed => $observed, expected => $state);
$result;
__
meta::function('waul', <<'__');
my ($name, %options) = @_;
$name =~ s/^waul:://;
my $output     = $options{output} || "$name.js";
my $extensions = $options{extensions} ? join(' ', map "--extension '$_'", split /\s+/, $options{extensions}) : '';
my $waul       = retrieve("waul::$name") =~ m-^#!/usr/bin/env (\S+)- ? $1 : 'waul';

terminal::info("compiling waul::$name using $waul ($extensions)");

with_exported("waul::$name", sub {
  my ($exported) = @_;
  sh("$waul --output '$output' $extensions $exported")});

__
meta::hook('before-shell::ad', <<'__');
ad('waul::');

__
meta::indicator('cc', 'length ::retrieve(\'data::current-continuation\') ? "\\033[1;36mcc\\033[0;0m" : \'\';');
meta::indicator('locked', 'is_locked() ? "\\033[1;31mlocked\\033[0;0m" : \'\';');
meta::indicator('path', <<'__');
my @highlighted = map join("\033[1;30m|\033[0;0m", split /\|/, $_), @{$transient{path}};
join "\033[1;30m/\033[0;0m", @highlighted;

__
meta::internal_function('around_hook', <<'__');
# around_hook('hookname', @args, sub {
#   stuff;
# });

# Invokes 'before-hookname' on @args before the sub runs, invokes the
# sub on @args, then invokes 'after-hookname' on @args afterwards.
# The after-hook is not invoked if the sub calls 'die' or otherwise
# unwinds the stack.

my $hook = shift @_;
my $f    = pop @_;

hook("before-$hook", @_);
my $result = &$f(@_);
hook("after-$hook", @_);
$result;
__
meta::internal_function('associate', <<'__');
my ($name, $value, %options) = @_;
die "Namespace does not exist" unless exists $datatypes{namespace($name)};
$data{$name} = $value;
execute($name) if $options{execute};
$value;

__
meta::internal_function('attribute', <<'__');
my ($name) = @_;
$name =~ s/^[^:]*:://;
$name;
__
meta::internal_function('attribute_is', <<'__');
my ($a, %options) = @_;
my %inherited     = parent_attributes(grep /^parent::/o, sort keys %data) if grep exists $options{$_}, qw/-u -U -d -D/;
my $criteria      = $options{'--criteria'} || $options{'--namespace'} && "^$options{'--namespace'}::" || '.';

my %tests = ('-u' => sub {! $inherited{$a}},
             '-d' => sub {$inherited{$a} && fast_hash(retrieve($a)) ne $inherited{$a}},
             '-i' => sub {$transient{inherit}{namespace($a)}},
             '-v' => sub {$transient{virtual}{namespace($a)}},
             '-s' => sub {$a =~ /^state::/o},
             '-m' => sub {$a =~ /^meta::/o});

return 0 unless scalar keys %tests == scalar grep ! exists $options{$_}    ||   &{$tests{$_}}(), keys %tests;
return 0 unless scalar keys %tests == scalar grep ! exists $options{uc $_} || ! &{$tests{$_}}(), keys %tests;

$a =~ /$_/ || return 0 for @{$options{'--path'}};
$a =~ /$criteria/;

__
meta::internal_function('cache', <<'__');
my ($name, %pairs) = @_;
if (%pairs) {associate("cache::$name", join "\n", map {$pairs{$_} =~ s/\n//g; "$_ $pairs{$_}"} sort keys %pairs)}
else        {map split(/\s/, $_, 2), split /\n/, retrieve("cache::$name")}
__
meta::internal_function('chmod_self', <<'__');
my ($mode_function)      = @_;
my (undef, undef, $mode) = stat $0;
chmod &$mode_function($mode), $0;
__
meta::internal_function('dangerous', <<'__');
# Wraps a computation that may produce an error.
my ($message, $computation) = @_;
terminal::info($message) if $message;
my @result = eval {&$computation()};
terminal::warning(translate_backtrace($@)), return undef if $@;
wantarray ? @result : $result[0];
__
meta::internal_function('debug_trace', <<'__');
terminal::debug(join ', ', @_);
wantarray ? @_ : $_[0];
__
meta::internal_function('execute', <<'__');
my ($name, %options) = @_;
my $namespace = namespace($name);
eval {&{$datatypes{$namespace}}(attribute($name), retrieve($name))};
warn $@ if $@ && $options{'carp'};

__
meta::internal_function('exported', <<'__');
# Allocates a temporary file containing the concatenation of attributes you specify,
# and returns the filename. The filename will be safe for deletion anytime.
my $filename = temporary_name();
file::write($filename, cat(@_));
$filename;

__
meta::internal_function('extension_for', <<'__');
my $extension = $transient{extension}{namespace($_[0])};
$extension = &$extension($_[0]) if ref $extension eq 'CODE';
$extension || '';
__
meta::internal_function('fast_hash', <<'__');
my ($data)     = @_;
my $piece_size = length($data) >> 3;

my @pieces     = (substr($data, $piece_size * 8) . length($data), map(substr($data, $piece_size * $_, $piece_size), 0 .. 7));
my @hashes     = (fnv_hash($pieces[0]));

push @hashes, fnv_hash($pieces[$_ + 1] . $hashes[$_]) for 0 .. 7;

$hashes[$_] ^= $hashes[$_ + 4] >> 16 | ($hashes[$_ + 4] & 0xffff) << 16 for 0 .. 3;
$hashes[0]  ^= $hashes[8];

sprintf '%08x' x 4, @hashes[0 .. 3];
__
meta::internal_function('file::read', <<'__');
my $name = shift;
open my($handle), "<", $name;
my $result = join "", <$handle>;
close $handle;
$result;
__
meta::internal_function('file::write', <<'__');
use File::Path     'mkpath';
use File::Basename 'dirname';

my ($name, $contents, %options) = @_;
die "Choosing not to overwrite file $name" if $options{noclobber} and -f $name;
mkpath(dirname($name)) if $options{mkpath};

open my($handle), $options{append} ? '>>' : '>', $name or die "Can't open $name for writing";
print $handle $contents;
close $handle;
__
meta::internal_function('fnv_hash', <<'__');
# A rough approximation to the Fowler-No Voll hash. It's been 32-bit vectorized
# for efficiency, which may compromise its effectiveness for short strings.

my ($data) = @_;

my ($fnv_prime, $fnv_offset) = (16777619, 2166136261);
my $hash                     = $fnv_offset;
my $modulus                  = 2 ** 32;

$hash = ($hash ^ ($_ & 0xffff) ^ ($_ >> 16)) * $fnv_prime % $modulus for unpack 'L*', $data . substr($data, -4) x 8;
$hash;
__
meta::internal_function('hypothetically', <<'__');
# Applies a temporary state and returns a serialized representation.
# The original state is restored after this, regardless of whether the
# temporary state was successful.

my %data_backup   = %data;
my ($side_effect) = @_;
my $return_value  = eval {&$side_effect()};
%data = %data_backup;

die $@ if $@;
$return_value;
__
meta::internal_function('internal::main', <<'__');
disable();

$SIG{'INT'} = sub {snapshot(); exit 1};

$transient{initial}      = state();
chomp(my $default_action = retrieve('data::default-action'));

my $function_name = shift(@ARGV) || $default_action || 'usage';
terminal::warning("unknown action: '$function_name'") and $function_name = 'usage' unless $externalized_functions{$function_name};

around_hook('main-function', $function_name, @ARGV, sub {
  dangerous('', sub {
    chomp(my $result = &$function_name(@ARGV));
    print "$result\n" if $result})});

save() unless state() eq $transient{initial};

END {
  enable();
}
__
meta::internal_function('invoke_editor_on', <<'__');
my ($data, %options) = @_;
my $editor    = $options{editor} || $ENV{VISUAL} || $ENV{EDITOR} || die 'Either the $VISUAL or $EDITOR environment variable should be set to a valid editor';
my $options   = $options{options} || $ENV{VISUAL_OPTS} || $ENV{EDITOR_OPTS} || '';
my $attribute = $options{attribute};
$attribute =~ s/\//-/g;
my $filename  = temporary_name() . "-$attribute$options{extension}";

file::write($filename, $data);
system("$editor $options '$filename'");

my $result = file::read($filename);
unlink $filename;
$result;
__
meta::internal_function('is_locked', '!((stat($0))[2] & 0222);');
meta::internal_function('namespace', <<'__');
my ($name) = @_;
$name =~ s/::.*$//;
$name;
__
meta::internal_function('parent_attributes', <<'__');
my $attributes = sub {my ($name, $value) = split /\s+/o, $_; $name => ($value || 1)};
map &$attributes(), split /\n/o, join("\n", retrieve(@_));
__
meta::internal_function('parent_ordering', <<'__');
# Topsorts the parents by dependency chain. The simplest way to do this is to
# transitively compute the number of parents referred to by each parent.

my @parents = @_;
my %all_parents = map {$_ => 1} @parents;

my %parents_of = map {
  my $t = $_;
  my %attributes = parent_attributes($_);
  $t => [grep /^parent::/, keys %attributes]} @parents;

my %parent_count;
my $parent_count;
$parent_count = sub {
  my ($key) = @_;
  return $parent_count{$key} if exists $parent_count{$key};
  my $count = 0;
  $count += $parent_count->($_) + exists $data{$_} for @{$parents_of{$key}};
  $parent_count{$key} = $count};

my %inverses;
push @{$inverses{$parent_count->($_)} ||= []}, $_ for @parents;
grep exists $all_parents{$_}, map @{$inverses{$_}}, sort keys %inverses;
__
meta::internal_function('retrieve', <<'__');
my @results = map defined $data{$_} ? $data{$_} : retrieve_with_hooks($_), @_;
wantarray ? @results : $results[0];

__
meta::internal_function('retrieve_with_hooks', <<'__');
# Uses the hooks defined in $transient{retrievers}, and returns undef if none work.
my ($attribute) = @_;
my $result      = undef;

defined($result = &$_($attribute)) and return $result for map $transient{retrievers}{$_}, sort keys %{$transient{retrievers}};
return undef;
__
meta::internal_function('select_keys', <<'__');
my %options = @_;
grep attribute_is($_, %options), sort keys %data;
__
meta::internal_function('separate_options', <<'__');
# Things with one dash are short-form options, two dashes are long-form.
# Characters after short-form are combined; so -auv4 becomes -a -u -v -4.
# Also finds equivalences; so --foo=bar separates into $$options{'--foo'} eq 'bar'.
# Stops processing at the -- option, and removes it. Everything after that
# is considered to be an 'other' argument.

# The only form not supported by this function is the short-form with argument.
# To pass keyed arguments, you need to use long-form options.

my @parseable;
push @parseable, shift @_ until ! @_ or $_[0] eq '--';

my @singles = grep /^-[^-]/, @parseable;
my @longs   = grep /^--/,    @parseable;
my @others  = grep ! /^-/,   @parseable;

my @singles = map /-(.{2,})/ ? map("-$_", split(//, $1)) : $_, @singles;

my %options;
/^([^=]+)=(.*)$/ and $options{$1} = $2 for @longs;
++$options{$_} for grep ! /=/, @singles, @longs;

({%options}, @others, @_);

__
meta::internal_function('strip', 'wantarray ? map {s/^\\s*|\\s*$//g; $_} @_ : $_[0] =~ /^\\s*(.*?)\\s*$/ && $1;');
meta::internal_function('table_display', <<'__');
# Displays an array of arrays as a table; that is, with alignment. Arrays are
# expected to be in column-major order.

sub maximum_length_in {
  my $maximum = 0;
  length > $maximum and $maximum = length for @_;
  $maximum;
}

my @arrays    = @_;
my @lengths   = map maximum_length_in(@$_), @arrays;
my @row_major = map {my $i = $_; [map $$_[$i], @arrays]} 0 .. $#{$arrays[0]};
my $format    = join '  ', map "%-${_}s", @lengths;

join "\n", map strip(sprintf($format, @$_)), @row_major;
__
meta::internal_function('temporary_name', <<'__');
use File::Temp 'tempfile';
my (undef, $temporary_filename) = tempfile("$0." . 'X' x 4, OPEN => 0);
$temporary_filename;
__
meta::internal_function('translate_backtrace', <<'__');
my ($trace) = @_;
$trace =~ s/\(eval (\d+)\)/$locations{$1 - 1}/g;
$trace;
__
meta::internal_function('with_exported', <<'__');
# Like exported(), but removes the file after running some function.
# Usage is with_exported(@files, sub {...});
my $f      = pop @_;
my $name   = exported(@_);
my $result = eval {&$f($name)};
terminal::warning("$@ when running with_exported()") if $@;
unlink $name;
$result;
__
meta::library('shell', <<'__');
# Functions for shell parsing and execution.
package shell;
use Term::ReadLine;

sub tokenize {grep length, split /\s+|("[^"\\]*(?:\\.)?")/o, join ' ', @_};

sub parse {
  my ($fn, @args) = @_;
  s/^"(.*)"$/\1/o, s/\\\\"/"/go for @args;
  {function => $fn, args => [@args]}}

sub execute {
  my %command = %{$_[0]};
  die "undefined command: $command{function}" unless exists $externalized_functions{$command{function}};
  &{"::$command{function}"}(@{$command{args}})}

sub run {execute(parse(tokenize(@_)))}

sub prompt {
  my %options = @_;
  my $name    = $options{name} // ::name();

  my $indicators = join '', map &{"::$_"}(), ::select_keys('--namespace' => 'indicator');
  my $prefix     = $transient{repl_prefix} // '';

  "$prefix\033[1;32m$name\033[0;0m$indicators "}

sub repl {
  my %options = @_;

  my $term = new Term::ReadLine "$0 shell";
  $term->ornaments(0);
  my $attribs = $term->Attribs;
  $attribs->{completion_entry_function} = $attribs->{list_completion_function};

  my $autocomplete = $options{autocomplete} || sub {[sort(keys %data), grep !/-/, sort keys %externalized_functions]};
  my $prompt       = $options{prompt}       || \&prompt;
  my $parse        = $options{parse}        || sub {parse(tokenize(@_))};
  my $output       = $options{output}       || sub {print join("\n", @_), "\n"};
  my $command      = $options{command}      || sub {my ($command) = @_; ::around_hook('shell-command', $command, sub {&$output(::dangerous('', sub {execute($command)}))})};

  length $_ && &$command(&$parse($_)) while ($attribs->{completion_word} = &$autocomplete(), defined($_ = $term->readline(&$prompt())))}

__
meta::library('terminal', <<'__');
# Functions for nice-looking terminal output.
package terminal;

my $process = ::name();

sub message {print STDERR "[$_[0]] $_[1]\n"}
sub color {
  my ($name, $color) = @_;
  *{"terminal::$name"} = sub {chomp($_), print STDERR "\033[1;30m$process(\033[1;${color}m$name\033[1;30m)\033[0;0m $_\n" for map join('', $_), @_}}

my %preloaded = (info => 32, progress => 32, state => 34, debug => 34, warning => 33, error => 31);
color $_, $preloaded{$_} for keys %preloaded;
__
meta::message_color('cc', '36');
meta::message_color('state', 'purple');
meta::message_color('states', 'yellow');
meta::parent('/home/spencertipping/bin/object', <<'__');
bootstrap::html                         f44dd03cb0c904b3a5f69fbda5f018d0
bootstrap::initialization               d22fafa2938ecb0d4728e2958b54ed3d
bootstrap::perldoc                      5793df44bdd2526bb461272924abfd4b
function::ad                            9220b9dc131f8f79878a6209adfe8ef2
function::alias                         8eeeeb4e064ef3aba7edf8f254427bc2
function::cat                           f684de6c8776617a437b76009114f52e
function::cc                            12ea9176e388400704d823433c209b7a
function::ccc                           d151a9793edd83f80fb880b7f0ab9b34
function::child                         f5764adf0b4e892f147a9b6b68d4816f
function::clone                         bb42e04e10a8e54e88786b6fbc4fb213
function::cp                            3fe69d1b58d90045ad520048977538c4
function::create                        3010d55f4dfa59a998742e07823ed54d
function::current-state                 6f03f86f1901e9ef07fdb5d4079a914c
function::disable                       53b449708cc2ffdefa352e53bb7d847d
function::edit                          beae8b1d7292e2ce2913199ff32f2501
function::edit-self                     71790df00f941ed9b56e17f789b93871
function::enable                        7de1cedc36841f5de8f9fdfbc3b65097
function::export                        2374cd1dbf7616cb38cafba4e171075d
function::extern                        1290a5223e2824763eecfb3a54961eff
function::grep                          55c3cea8ff4ec2403be2a9d948e59f14
function::hash                          6ee131d093e95b80039b4df9c7c84a02
function::hook                          675cdb98b5dd8567bdd5a02ead6184b5
function::hooks                         3d989899c616f7440429a2d9bf1cc44b
function::identity                      6523885762fcc2f354fc25cf6ed126ce
function::import                        5d0f0634cbd01274f2237717507198a2
function::initial-state                 03d8ed608855a723124e79ca184d8e73
function::is                            41564c8f21b12ab80824ac825266d805
function::load-state                    b6cf278a1f351f316fa6e070359b6081
function::lock                          5d8db258704e6a8623fac796f62fac02
function::ls                            01a23d51d5b529e03943bd57e33f92df
function::mv                            ccd000960db4cf627d9246c43d87ba4c
function::name                          955ba2d1fe1d67cd78651a4042283b00
function::parents                       3da9e63b5aae9e2f5dcc946a86d166aa
function::perl                          9f9fd744f0ed225ad8fb3b79fa53dd9a
function::rd                            2adb16d7e819d2e87a27201744a581e7
function::reload                        1589f4cf8374e0011991cb8907afca3e
function::rm                            6f6fd7a6c25558eb469d78ea888f8551
function::rmparent                      fc2884910a6939a47898a778f277332c
function::save                          778c0e1043b9c6c96fb8f266f8061624
function::save-state                    5af59ebc4ad8965767e4dc106d3b557e
function::serialize                     e08b4ed30b5a27e7d5b3cbce5901996f
function::serialize-single              8bac97e94a1162947d274421053387b0
function::sh                            1b2f542ca9dd63ad437058b7f6f61aac
function::shb                           7b2685a4041c25bc495816e472bdace5
function::shell                         a87f389b94713e5855e62241d649d01d
function::size                          69f6ab4a100c6ef05d4d41510004d645
function::snapshot                      56939a47f2758421669641e15ebd66eb
function::state                         f7490e937bec0d67edde576f6d86d8e9
function::touch                         3991b1b7c7187566f50e5e58ce01fa06
function::unlock                        b4aac02f7f3fb700acf4acfd9b180ceb
function::update                        ac391dc90e507e7586c81850e7c2ecdd
function::update-from                   06fef658374d482adb2e62fbeed9efb4
function::usage                         5bdd370f5a56cfbf199e08d398091444
function::verify                        0c0cc1dfeab7d705919df122f7850a4f
indicator::cc                           3db7509c521ee6abfedd33d5f0148ed3
indicator::locked                       fc2b4f4ca0d6a334b9ac423d06c8f18c
indicator::path                         b5e2cb524caa0283f713a0ddf9f4c162
internal_function::around_hook          7cc876e7c5f78c34654337fc95255587
internal_function::associate            55f202ffdbc6b9005e53d3e82f5f9bfe
internal_function::attribute            dd6f010f9688977464783f60f5b6d3dd
internal_function::attribute_is         d28ac825b3937029386372c560a65775
internal_function::cache                eb9da45580a9ac0882baf98acd2ecd60
internal_function::chmod_self           2035e861eedab55ba0a9f6f5a068ca70
internal_function::dangerous            46c4baaa214ab3d05af43e28083d5141
internal_function::debug_trace          0faf9d9f4159d72dfe4481f6f3607ce1
internal_function::execute              f0924e087d978ff2ab1e117124db3042
internal_function::exported             ae35afef7d4762f2818aee5872c75be0
internal_function::extension_for        9de8261d69cc93e9b92072b89c89befd
internal_function::fast_hash            ee5eba48f837fda0fe472645fdd8899a
internal_function::file::read           e647752332c8e05e81646a3ff98f9a8e
internal_function::file::write          3e290fdcb353c6f842eb5a40f2e575f8
internal_function::fnv_hash             c36d56f1e13a60ae427afc43ba025afc
internal_function::hypothetically       b83e3f894a6df8623ccd370515dfd976
internal_function::internal::main       f31f2945a19a668d92505f114ab29c78
internal_function::invoke_editor_on     5eb976796f0ec172d6ec036116a2f41e
internal_function::is_locked            da12ced6aa38295251f7e748ffd22925
internal_function::namespace            784d2e96003550681a4ae02b8d6d0a27
internal_function::parent_attributes    f6ccfaa982ab1a4d066043981aaca277
internal_function::parent_ordering      57b6da88f76b59f3fed9abfa61280e5e
internal_function::retrieve             721a6800f328da05047fd7392758f55d
internal_function::retrieve_with_hooks  0f1b0220ccd973d57a2e96ff00458cf2
internal_function::select_keys          a5e3532ec6d58151d0ee24416ea1e2b5
internal_function::separate_options     34ec41a6edaa15adde607a0db3ccfa36
internal_function::strip                14f490b10ebd519e829d8ae20ea4d536
internal_function::table_display        d575f4dc873b2e0be5bd7352047fd904
internal_function::temporary_name       6f548d101fc68356515ffd0fc9ae0c93
internal_function::translate_backtrace  d77a56d608473b3cd8a3c6cb84185e10
internal_function::with_exported        df345d5095d5ed13328ddd07ea922b36
library::shell                          f561500cf223df1bf6daf43af93577a5
library::terminal                       7e2d045782405934a9614fe04bcfe559
message_color::cc                       2218ef0f7425de5c717762ffb100eb43
message_color::state                    03621cd6ac0b1a40d703f41e26c5807f
message_color::states                   ac66eeeff487b5f43f88a78ea18b3d56
meta::configure                         69c2e727c124521d074fde21f8bbc4db
meta::externalize                       aa44e27e0bbee6f0ca4de25d603a1fc7
meta::functor::editable                 48246c608f363de66511400e00b26164
meta::type::alias                       889d26d2df385e9ff8e2da7de4e48374
meta::type::bootstrap                   51108ab2ddb8d966e927c8f62d9ef3e5
meta::type::cache                       9267171f2eace476f64a1a670eaaf2c7
meta::type::data                        120e1649a468d3b3fd3fb783b4168499
meta::type::function                    8ea626198861dc59dd7f303eecb5ff88
meta::type::hook                        ff92aef328b6bdc6f87ddd0821f3e42f
meta::type::inc                         78e0375b6725487cb1f0deca41e96bbe
meta::type::indicator                   feb54a2624e6983617685047c717427f
meta::type::internal_function           eff3cf31e2635f51c83836f116c99d2f
meta::type::library                     7622e8d65e03066668bade74715d65ad
meta::type::message_color               557a1b44979cbf77a7251fbdc4c5b82c
meta::type::meta                        c6250056816b58a9608dd1b2614246f8
meta::type::parent                      09d1d03379e4e0b262e06939f4e00464
meta::type::retriever                   71a29050bf9f20f6c71afddff83addc9
meta::type::state                       84da7d5220471307f1f990c5057d3319
retriever::file                         3bbc9d8a887a536044bafff1d54def7e
retriever::global                       4fe8df0cca548075169968772843a156
retriever::id                           4da6080168d32445150cc4200af7af6e
retriever::object                       c7633990b4e01bdc783da7e545799f4f
retriever::perl                         f41938e6dbad317f62abffc1e4d28cca

__
meta::parent('/home/spencertipping/bin/waul-object', <<'__');
function::minify-yui                                        6374d98eda8642e5cdebe4fb34f5419b
function::waul                                              66b92f55d5db498934b487188a04b16d
meta::type::waul                                            869b5820cd79178b94c3ccdd47dff9df
parent::/home/spencertipping/conjectures/perl-objects/js    321c17e6588bd0964c94cf41f4ebfa44
parent::/home/spencertipping/conjectures/perl-objects/sdoc  7c88dbaab3054123708cf8ca914f4845
parent::preprocessor                                        e3ff51a281479e1af0e8adad2937e03e

__
meta::parent('/home/spencertipping/conjectures/perl-objects/js', <<'__');
meta::type::js                           0377fcc438f3af85ec87d4770b8cd307
parent::/home/spencertipping/bin/object  b23425ebecdd41cce4007aae410aa36e

__
meta::parent('/home/spencertipping/conjectures/perl-objects/sdoc', <<'__');
function::sdoc                           b2f9066417ce3368f093796e1180e9b2
function::sdoc-html                      b23152b3f5be696e5bae842ec43fc5a4
function::sdoc-markdown                  a35a6441dd750466f2d0e636bee2b382
function::sdocp                          c3d738d982ba87418a298ff58478a85b
meta::type::sdoc                         22cd7315641d38c9d536344e83c36bed
meta::type::slibrary                     95474943c4a5f8ff17d3cf66ddb7c386
parent::/home/spencertipping/bin/object  b23425ebecdd41cce4007aae410aa36e
retriever::code-sdoc                     03b87ff8d1ecf7594db9ca0669fc69a1
retriever::html-sdoc                     8ab7705d03276945b23a71677153233c
retriever::markdown-sdoc                 67c34ba8223ec36a3ae018e411354db2
retriever::sdoc                          662061e9e41491e2a1debd6862ccf1e7
retriever::sdocp                         330694ea14a23bb04b65c761075cd946

__
meta::parent('object', <<'__');
bootstrap::html                         f44dd03cb0c904b3a5f69fbda5f018d0
bootstrap::initialization               d22fafa2938ecb0d4728e2958b54ed3d
bootstrap::perldoc                      5793df44bdd2526bb461272924abfd4b
function::ad                            9220b9dc131f8f79878a6209adfe8ef2
function::alias                         8eeeeb4e064ef3aba7edf8f254427bc2
function::cat                           f684de6c8776617a437b76009114f52e
function::cc                            12ea9176e388400704d823433c209b7a
function::ccc                           d151a9793edd83f80fb880b7f0ab9b34
function::child                         f5764adf0b4e892f147a9b6b68d4816f
function::clone                         bb42e04e10a8e54e88786b6fbc4fb213
function::cp                            3fe69d1b58d90045ad520048977538c4
function::create                        3010d55f4dfa59a998742e07823ed54d
function::current-state                 6f03f86f1901e9ef07fdb5d4079a914c
function::disable                       53b449708cc2ffdefa352e53bb7d847d
function::edit                          beae8b1d7292e2ce2913199ff32f2501
function::edit-self                     71790df00f941ed9b56e17f789b93871
function::enable                        7de1cedc36841f5de8f9fdfbc3b65097
function::export                        2374cd1dbf7616cb38cafba4e171075d
function::extern                        1290a5223e2824763eecfb3a54961eff
function::grep                          55c3cea8ff4ec2403be2a9d948e59f14
function::hash                          6ee131d093e95b80039b4df9c7c84a02
function::hook                          675cdb98b5dd8567bdd5a02ead6184b5
function::hooks                         3d989899c616f7440429a2d9bf1cc44b
function::identity                      6523885762fcc2f354fc25cf6ed126ce
function::import                        5d0f0634cbd01274f2237717507198a2
function::initial-state                 03d8ed608855a723124e79ca184d8e73
function::is                            41564c8f21b12ab80824ac825266d805
function::load-state                    b6cf278a1f351f316fa6e070359b6081
function::lock                          5d8db258704e6a8623fac796f62fac02
function::ls                            01a23d51d5b529e03943bd57e33f92df
function::mv                            ccd000960db4cf627d9246c43d87ba4c
function::name                          955ba2d1fe1d67cd78651a4042283b00
function::parents                       3da9e63b5aae9e2f5dcc946a86d166aa
function::perl                          9f9fd744f0ed225ad8fb3b79fa53dd9a
function::rd                            2adb16d7e819d2e87a27201744a581e7
function::reload                        1589f4cf8374e0011991cb8907afca3e
function::rm                            6f6fd7a6c25558eb469d78ea888f8551
function::rmparent                      fc2884910a6939a47898a778f277332c
function::save                          778c0e1043b9c6c96fb8f266f8061624
function::save-state                    5af59ebc4ad8965767e4dc106d3b557e
function::serialize                     e08b4ed30b5a27e7d5b3cbce5901996f
function::serialize-single              8bac97e94a1162947d274421053387b0
function::sh                            1b2f542ca9dd63ad437058b7f6f61aac
function::shb                           7b2685a4041c25bc495816e472bdace5
function::shell                         a87f389b94713e5855e62241d649d01d
function::size                          69f6ab4a100c6ef05d4d41510004d645
function::snapshot                      56939a47f2758421669641e15ebd66eb
function::state                         f7490e937bec0d67edde576f6d86d8e9
function::touch                         3991b1b7c7187566f50e5e58ce01fa06
function::unlock                        b4aac02f7f3fb700acf4acfd9b180ceb
function::update                        ac391dc90e507e7586c81850e7c2ecdd
function::update-from                   06fef658374d482adb2e62fbeed9efb4
function::usage                         5bdd370f5a56cfbf199e08d398091444
function::verify                        0c0cc1dfeab7d705919df122f7850a4f
indicator::cc                           3db7509c521ee6abfedd33d5f0148ed3
indicator::locked                       fc2b4f4ca0d6a334b9ac423d06c8f18c
indicator::path                         b5e2cb524caa0283f713a0ddf9f4c162
internal_function::around_hook          7cc876e7c5f78c34654337fc95255587
internal_function::associate            55f202ffdbc6b9005e53d3e82f5f9bfe
internal_function::attribute            dd6f010f9688977464783f60f5b6d3dd
internal_function::attribute_is         d28ac825b3937029386372c560a65775
internal_function::cache                eb9da45580a9ac0882baf98acd2ecd60
internal_function::chmod_self           2035e861eedab55ba0a9f6f5a068ca70
internal_function::dangerous            46c4baaa214ab3d05af43e28083d5141
internal_function::debug_trace          0faf9d9f4159d72dfe4481f6f3607ce1
internal_function::execute              f0924e087d978ff2ab1e117124db3042
internal_function::exported             ae35afef7d4762f2818aee5872c75be0
internal_function::extension_for        9de8261d69cc93e9b92072b89c89befd
internal_function::fast_hash            ee5eba48f837fda0fe472645fdd8899a
internal_function::file::read           e647752332c8e05e81646a3ff98f9a8e
internal_function::file::write          3e290fdcb353c6f842eb5a40f2e575f8
internal_function::fnv_hash             c36d56f1e13a60ae427afc43ba025afc
internal_function::hypothetically       b83e3f894a6df8623ccd370515dfd976
internal_function::internal::main       f31f2945a19a668d92505f114ab29c78
internal_function::invoke_editor_on     5eb976796f0ec172d6ec036116a2f41e
internal_function::is_locked            da12ced6aa38295251f7e748ffd22925
internal_function::namespace            784d2e96003550681a4ae02b8d6d0a27
internal_function::parent_attributes    f6ccfaa982ab1a4d066043981aaca277
internal_function::parent_ordering      57b6da88f76b59f3fed9abfa61280e5e
internal_function::retrieve             721a6800f328da05047fd7392758f55d
internal_function::retrieve_with_hooks  0f1b0220ccd973d57a2e96ff00458cf2
internal_function::select_keys          a5e3532ec6d58151d0ee24416ea1e2b5
internal_function::separate_options     34ec41a6edaa15adde607a0db3ccfa36
internal_function::strip                14f490b10ebd519e829d8ae20ea4d536
internal_function::table_display        d575f4dc873b2e0be5bd7352047fd904
internal_function::temporary_name       6f548d101fc68356515ffd0fc9ae0c93
internal_function::translate_backtrace  d77a56d608473b3cd8a3c6cb84185e10
internal_function::with_exported        df345d5095d5ed13328ddd07ea922b36
library::shell                          f561500cf223df1bf6daf43af93577a5
library::terminal                       7e2d045782405934a9614fe04bcfe559
message_color::cc                       2218ef0f7425de5c717762ffb100eb43
message_color::state                    03621cd6ac0b1a40d703f41e26c5807f
message_color::states                   ac66eeeff487b5f43f88a78ea18b3d56
meta::configure                         69c2e727c124521d074fde21f8bbc4db
meta::externalize                       aa44e27e0bbee6f0ca4de25d603a1fc7
meta::functor::editable                 48246c608f363de66511400e00b26164
meta::type::alias                       889d26d2df385e9ff8e2da7de4e48374
meta::type::bootstrap                   51108ab2ddb8d966e927c8f62d9ef3e5
meta::type::cache                       9267171f2eace476f64a1a670eaaf2c7
meta::type::data                        120e1649a468d3b3fd3fb783b4168499
meta::type::function                    8ea626198861dc59dd7f303eecb5ff88
meta::type::hook                        ff92aef328b6bdc6f87ddd0821f3e42f
meta::type::inc                         78e0375b6725487cb1f0deca41e96bbe
meta::type::indicator                   feb54a2624e6983617685047c717427f
meta::type::internal_function           eff3cf31e2635f51c83836f116c99d2f
meta::type::library                     7622e8d65e03066668bade74715d65ad
meta::type::message_color               557a1b44979cbf77a7251fbdc4c5b82c
meta::type::meta                        c6250056816b58a9608dd1b2614246f8
meta::type::parent                      09d1d03379e4e0b262e06939f4e00464
meta::type::retriever                   71a29050bf9f20f6c71afddff83addc9
meta::type::state                       84da7d5220471307f1f990c5057d3319
retriever::file                         3bbc9d8a887a536044bafff1d54def7e
retriever::global                       4fe8df0cca548075169968772843a156
retriever::id                           4da6080168d32445150cc4200af7af6e
retriever::object                       c7633990b4e01bdc783da7e545799f4f
retriever::perl                         f41938e6dbad317f62abffc1e4d28cca

__
meta::parent('preprocessor', <<'__');
function::preprocess           ab5526a02ff417d4c162357dc327e7c4
meta::type::template           bc4b0c80b5efc716b19e99b832c22bf3
parent::object                 b23425ebecdd41cce4007aae410aa36e
retriever::pp                  3b5f5c5d30c5a04f72056dedaacfe7b7
template::comment              dfe273d2dad3d8159b847545e4e5c309
template::eval                 1a0e2124a05056be4abc11803883c294
template::failing_conditional  e3a4523110dd859e828f342185de7c62
template::include              47b5552d609d97fe7f2522d5c1027014
template::pinclude             c07ff79bf8d642cceaa9ef844bfcb189

__
meta::retriever('code-sdoc', <<'__');
# Lets you specify the SDoc extension manually. For instance:
# code.js::sdoc::foo causes sdoc::foo to be SDoc-rendered using Javascript comments.
my ($name) = @_;
return undef unless $name =~ s/^code\.(\w+)::// and defined retrieve($name);
sdoc($name, $1);

__
meta::retriever('file', '-f $_[0] ? file::read($_[0]) : undef;');
meta::retriever('global', <<'__');
# Returns the global data stashed at the end of this perl object
$_[0] eq 'self' ? $global_data : undef;

__
meta::retriever('html-sdoc', <<'__');
my ($attribute) = @_;
return undef unless $attribute =~ s/^html::/sdoc::/ and defined retrieve($attribute) || $attribute =~ s/^sdoc::// && defined retrieve($attribute);
sdoc_html($attribute);

__
meta::retriever('id', '$_[0] =~ /^id::/ ? substr($_[0], 4) : undef;');
meta::retriever('markdown-sdoc', <<'__');
my ($attribute) = @_;
return undef unless $attribute =~ s/^markdown::/sdoc::/ and defined retrieve($attribute) || $attribute =~ s/^sdoc::// && defined retrieve($attribute);
sdoc_markdown($attribute);

__
meta::retriever('object', <<'__');
# Fetch a property from another Perl object. This uses the 'cat' function.
return undef unless $_[0] =~ /^object::(.*?)::(.*)$/ && -x $1 && qx|$1 is '$2'|;
join '', qx|$1 cat '$2'|;

__
meta::retriever('perl', <<'__');
# Lets you use the result of evaluating some Perl expression
return undef unless $_[0] =~ /^perl::(.*)$/;
eval $1;

__
meta::retriever('pp', <<'__');
return undef unless namespace($_[0]) eq 'pp';
my $attr = retrieve(attribute($_[0]));
defined $attr ? preprocess($attr) : undef;
__
meta::retriever('sdoc', 'exists $data{"sdoc::$_[0]"} ? sdoc("sdoc::$_[0]") : undef;');
meta::retriever('sdocp', <<'__');
my $attribute = attribute($_[0]);
exists $data{"sdoc::$attribute"} ? sdocp("sdoc::$attribute") : undef;
__
meta::sdoc('waul::asm-x64', <<'__');
Caterwaul x86-64 low-level assembler | Spencer Tipping
Licensed under the terms of the MIT source code license

Introduction.
This assembler provides mnemonics for x86-64 assembly language commands, registers, and addressing modes. It also gives you a way to label and link code segments, though it is not guaranteed
to use the smallest possible jump command. Assemblers are static subclasses of bit-vectors.

caterwaul.module('asm.x64', ':all', function ($) {
  ($.asm_x64() = $.bit_vector.apply(this, arguments) -then- this.labels /eq.{} -then- this.links /eq.{})

Static members.
These are useful when combined with -using, as they give you easy ways to refer to all x64 general-purpose and SSE registers.

  -se- it /(n[8, 16] *[['r#{x}', x]]   -object -seq)
          /(n[0, 16] *[['xmm#{x}', x]] -object -seq)

Operand encoding.
Operands for most commands are encoded in a ModR/M byte, possibly with an SIB byte and displacement if memory is one of the operands. This library provides a few helpers to generate these
constructs. They are:

| 1. rr(op, r1, r2)           Generates a register-register instruction, creating a REX prefix if necessary.
  2. rm(op, r1, r2)           Generates a register-indirect instruction, creating a REX prefix if necessary. No SIB byte.
  3. rd(op, r1, d)            Generates a register-RIP-indirect instruction, creating a REX prefix if necessary. No SIB byte, displacement is a 32-bit vector.
  4. rm8(op, r1, r2, d)       Register-indirect + 8-bit displacement, no SIB byte. Displacement is specified as a bit vector, not a number.
  5. rm32(op, r1, r2, d)      Register-indirect + 32-bit displacement, no SIB byte. Displacement is specified as a bit vector, not a number.
  6. rs(op, r, s, i, b)       Register-indirect with SIB byte, no displacement. s must be 1, 2, 4, or 8.
  7. rs8(op, r, s, i, b, d)   Register-indirect with SIB byte, 8-bit displacement specified as a bit vector.
  8. rs32(op, r, s, i, b, d)  Register-indirect with SIB byte, 32-bit displacement specified as a bit vector.

These methods generally throw errors for invalid argument combinations, or any combinations that would be interpreted in a misleading way. For example, using the rm() form with r2 === rsp dies
because indirecting by %rsp indicates that an SIB byte will be present.

          /wcapture [rax = 0, rcx = 1, rdx = 2, rbx = 3, rsp = 4, rbp = 5, rsi = 6, rdi = 7,
                     al  = 0, cl  = 1, dl  = 2, bl  = 3, ah  = 4, ch  = 5, dh  = 6, bh  = 7,

                     assert(cond, s)         = new Error(s) /raise -unless- cond,

                     rex(r, x, b)            = b01001 << r << x << b |bitwise,
                     maybe_rex(r, x, b)      = r || x || b ? b01001 << r << x << b |bitwise : $.bit_vector(),
                     sib(s, i, b)            = $.bit_vector() << s%2 << i%3 << b%3 |bitwise,

                     rr(op, r1, r2)          = maybe_rex(r1 & 8, 0, r2 & 8) + op + (b11 << r1%3 << r2%3) -bitwise,

                     rd(op, r1, d)           = maybe_rex(r1 & 8, 0, 0)      + op + (b00 << r1%3 << rbp%3) + d[31%0] -bitwise,
                     rm(op, r1, r2)          = maybe_rex(r1 & 8, 0, r2 & 8) + op + (b00 << r1%3 << r2%3)            -bitwise -se- assert(r2     !== rsp, 's/rm(rsp)/rs()/')
                                                                                                                             -se- assert(r2     !== rbp, 's/rm(rbp)/rd()/')
                                                                                                                             -se- assert(r2 & 7 !== rbp, 's/rm(r13)/rm8(r13)/'),

                     rm8(op, r1, r2, d)      = maybe_rex(r1 & 8, 0, r2 & 8) + op + (b01 << r1%3 << r2%3) + d[7%0]   -bitwise -se- assert(r2     !== rsp, 's/rm8(rsp)/rs8()/'),
                     rm32(op, r1, r2, d)     = maybe_rex(r1 & 8, 0, r2 & 8) + op + (b10 << r1%3 << r2%3) + d[31%0]  -bitwise -se- assert(r2     !== rsp, 's/rm32(rsp)/rs32()/'),

                     rs(op, r, s, i, b)      = maybe_rex(r & 8, i & 8, b & 8) + op + (b00 << r%3 << rsp%3) + sib(s, i, b)           -bitwise,
                     rs8(op, r, s, i, b, d)  = maybe_rex(r & 8, i & 8, b & 8) + op + (b01 << r%3 << rsp%3) + sib(s, i, b) + d[7%0]  -bitwise,
                     rs32(op, r, s, i, b, d) = maybe_rex(r & 8, i & 8, b & 8) + op + (b10 << r%3 << rsp%3) + sib(s, i, b) + d[31%0] -bitwise]

Assembler commands.
These are encoded minimally as mnemonics for the opcode segment of the command. Many commands use ModR/M and SIB bytes, which are generated using helper methods. Opcodes provide no help in
determining the operands they accept; you need to know this up-front. Further, for unary operators that encode opcode bits in ModR/M, you're responsible for using rr() above to figure out
where the extra opcode bits go and writing them out manually.

In other words, this assembler totally sucks. However, it gives you lots of control about low-level encoding decisions. It also uses a more regular encoding to deal with reversible commands.
For example, movql moves a 64-bit value into its left operand, movqr moves a 64-bit value into its right operand. Normally this relationship is inferred by the assembler, making it sensitive
to operand order. The separate-opcode approach more closely mirrors the hardware model and gives you a more concise variant.

Instructions that are invalid in 64-bit protected mode are not listed here.

          /-$.merge/ wcapture [

              /* Arithmetic */ addbr = x00, addqr = x01, addbl = x02, addql = x03, addabl = x04, addaql = x05,   orbr  = x08, orqr  = x09, orbl  = x0a, orql  = x0b, orabl  = x0c, oraql  = x0d,
                               adcbr = x10, adcqr = x11, adcbl = x12, adcql = x13, adcabl = x14, adcaql = x15,   sbbbr = x18, sbbqr = x19, sbbbl = x1a, sbbql = x1b, sbbabl = x1c, sbbaql = x1d,
                               andbr = x20, andqr = x21, andbl = x22, andql = x23, andabl = x24, andaql = x25,   subbr = x28, subqr = x29, subbl = x2a, subql = x2b, subabl = x2c, subaql = x2d,
                               xorbr = x30, xorqr = x31, xorbl = x32, xorql = x33, xorabl = x34, xoraql = x35,   cmpbr = x38, cmpqr = x39, cmpbl = x3a, cmpql = x3b, cmpabl = x3c, cmpaql = x3d,

               /* stack ops */ push(r) = $.asm_x64.maybe_rex(0, 0, r & 8) + b01010 << r%3,  /* test, xchg */ testb = x84, testq = x85, xchgb = x86, xchgq = x87,
                               pop(r)  = $.asm_x64.maybe_rex(0, 0, r & 8) + b01011 << r%3,                   xchga(r) = $.asm_x64.maybe_rex(0, 0, r & 8) + b10010 << r%3,

                    /* movi */ movi(r) = $.asm_x64.maybe_rex(0, 0, r & 8) + b10111 << r%3,                   movql = x89, movqr = x8b,

                     /* jcc */ j(condition, d) = (x7 << condition%4) + d[7%0],  o = 0x0, no = 0x1, b = 0x2, nb = 0x3, z = 0x4, nz = 0x5, na = 0x6, a = 0x7,
                                                                                s = 0x8, ns = 0x9, p = 0xa, np = 0xb, l = 0xc, nl = 0xd, ng = 0xe, g = 0xf,

                   /* flags */ sahf = x9e, lahf = x9f, clc = xf8, stc = xf9,                     /* debug/control registers */ movcl = x0f20, movdl = x0f21, movcr = x0f22, movdr = x0f23,
            /* stack frames */ enter(size, level) = xc8 + size[15%0] + level[7%0], leave = xc9,                                rdtsc = x0f31, rdmsr = x0f32, rdpmc = x0f33,
                     /* int */ int(n) = xcd + n[7%0],                                                            /* syscall */ sysen = x0f34, sysex = x0f35,

                    /* SSE2 */ movupsl = x__0f10, movupsr = x__0f11, movupdl = x660f10, movupdr = x660f11,   unpcklps = x0f14, unpcklpd = x660f14,   ucomiss = x__0f2e, comiss = x__0f2f,
                               movssl  = xf30f10, movssr  = xf30f11, movsdl  = xf20f10, movsdr  = xf20f11,   unpckhps = x0f15, unpckhpd = x660f15,   ucomisd = x660f2e, comisd = x660f2f,

                               movapsl = x__0f28, movapsr = x__0f29, movapdl = x660f28, movapdr = x660f29,   cvttpsi = x__0f2c, cvttpdi = x660f2c, cvttssi = xf30f2c, cvttsdi = xf20f2c,
                               cvtpis  = x__0f2a, cvtpid  = x660f2a, cvtsis  = xf30f2a, cvtsid  = xf20f2a,   cvtpsi  = x__0f2d, cvtpdi  = x660f2d, cvtssi  = xf30f2d, cvtsdi  = xf20f2c,

                               movmskpsl = x__0f50,   sqrtpsl = x__0f51, sqrtssl = xf30f51,   rsqrtpsl = x__0f52,   rcppsl = x__0f53,
                               movmskpdl = x660f50,   sqrtpdl = x660f51, sqrtsdl = xf20f51,   rsqrtssl = xf30f52,   rcpssl = xf30f53,

                               andpsl = x__0f54, andnpsl = x__0f55, orpsl = x__0f56, xorpsl = x__0f57,
                               andpdl = x660f54, andnpdl = x660f55, orpdl = x660f56, xorpdl = x660f57,

                               addpsl = x__0f58, mulpsl = x__0f59,   cvtpsdl = x__0f5a, cvtpqsl  = x__0f5b,   subpsl = x__0f5c, minpsl = x__0f5d, divpsl = x__0f5e, maxpsl = x__0f5f,
                               addpdl = x660f58, mulpdl = x660f59,   cvtpdsl = x660f5a, cvtpqdl  = x660f5b,   subpdl = x660f5c, minpdl = x660f5d, divpdl = x660f5e, maxpdl = x660f5f,
                               addssl = xf30f58, mulssl = xf30f59,   cvtssdl = xf30f5a, cvttpsql = xf30f5b,   subssl = xf30f5c, minssl = xf30f5d, divssl = xf30f5e, maxssl = xf30f5f,
                               addsdl = xf20f58, mulsdl = xf20f59,   cvtsdsl = xf20f5a,                       subsdl = xf20f5c, minsdl = xf20f5d, divsdl = xf20f5e, maxsdl = xf20f5f,

                    /* cmov */ cmovl(condition) = x0f4 << condition%4, bitwise]});

__
meta::template('comment', '\'\';     # A mechanism for line or block comments.');
meta::template('eval', <<'__');
my $result = eval $_[0];
terminal::warning("Error during template evaluation: $@") if $@;
$result;
__
meta::template('failing_conditional', <<'__');
my ($commands)    = @_;
my $should_return = $commands =~ / if (.*)$/ && ! eval $1;
terminal::warning("eval of template condition failed: $@") if $@;
$should_return;
__
meta::template('include', <<'__');
my ($commands) = @_;
return '' if template::failing_conditional($commands);
join "\n", map retrieve($_), split /\s+/, $commands;
__
meta::template('pinclude', <<'__');
# Just like the regular include, but makes sure to insert paragraph boundaries
# (this is required for SDoc to function properly).

my ($commands) = @_;
return '' if template::failing_conditional($commands);
my $text = join "\n\n", map retrieve($_), split /\s+/, $commands;
"\n\n$text\n\n";
__
internal::main();

__DATA__
