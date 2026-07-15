# frozen_string_literal: true

class StudioPreviewPage
  attr_reader :controls

  def initialize(page)
    @page = page
    @controls = []
  end

  def add(control)
    @controls << control unless control.nil?
    self
  end

  def clean
    @controls.clear
    self
  end

  def title=(_value); end
  def theme_mode=(_value); end
  def bgcolor=(_value); end

  def method_missing(name, *args, **kwargs, &block)
    @page.public_send(name, *args, **kwargs, &block)
  end

  def respond_to_missing?(name, include_private = false)
    @page.respond_to?(name, include_private) || super
  end
end

# Render the example's own source (the editable string) into a preview.
# Fresh binding whose `self` is the studio's main object, so the DSL (text,
# column, spinkit, ...) resolves directly — no sandbox. The app body runs *in*
# this binding (not a lambda) so its locals (e.g. `count`) live in the binding
# and can be carried across re-runs for best-effort hot reload.
def new_preview_binding
  binding
end

# Split `… defs … Ruflet.run do |page| BODY end` into [prelude, body].
# Prelude = requires/helper defs before the run block; body = the block contents
# (the trailing standalone `end` that closes the block is dropped).
def split_ruflet_run(source)
  marker = source.match(/Ruflet\s*\.\s*run\s+do\s*\|\s*page\s*\|/)
  raise "Code must contain `Ruflet.run do |page|`" unless marker

  prelude = source[0...marker.begin(0)]
  rest = source[marker.end(0)..]
  lines = rest.lines
  last_end = nil
  lines.each_with_index { |line, i| last_end = i if line.strip == "end" }
  raise "Code must contain `Ruflet.run do |page|`" unless last_end

  [prelude, lines[0...last_end].join]
end

# Values safe to carry across a hot reload: plain state, never live view objects
# (controls) or handlers (procs). Collections carry only if they hold no controls.
def preview_state_value?(value)
  case value
  when Ruflet::Control, Proc then false
  when Integer, Float, String, Symbol, TrueClass, FalseClass, NilClass then true
  when Array then value.all? { |element| preview_state_value?(element) }
  when Hash then value.values.all? { |element| preview_state_value?(element) }
  else false
  end
end

# Renders the example's editable source into a preview. When a session is given,
# the body runs in a persistent binding so mutated state (counters, lists, …)
# is carried over on each Run — only the *view* is rebuilt from the new code.
# Note: editing an initial value (e.g. `count = 0` → `5`) won't take effect until
# the binding is reset (reload the app / reopen the example), matching hot-reload
# semantics — Run re-applies the view but keeps live state.
def render_example_code(page, source, session: nil)
  prelude, body = split_ruflet_run(source)
  preview_page = StudioPreviewPage.new(page)

  eval_binding = session && session[:eval_binding]
  eval_binding ||= new_preview_binding
  session[:eval_binding] = eval_binding if session

  carried = {}
  if session && session[:eval_started]
    eval_binding.local_variables.each do |name|
      next if name == :page

      value = eval_binding.local_variable_get(name)
      carried[name] = value if preview_state_value?(value)
    end
  end

  eval_binding.local_variable_set(:page, preview_page)
  eval("#{prelude}\n#{body}", eval_binding) # rubocop:disable Security/Eval

  carried.each do |name, value|
    eval_binding.local_variable_set(name, value) if eval_binding.local_variables.include?(name)
  end
  session[:eval_started] = true if session

  controls = preview_page.controls
  raise "The app did not add any controls to the page" if controls.empty?

  controls.length == 1 ? controls.first : column(spacing: 0, children: controls)
end
