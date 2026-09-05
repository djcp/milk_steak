// Test-environment determinism. Loaded only when Rails.env.test? (see
// app/views/application/_javascript.html.erb), and only with defer: true so it
// runs after jQuery.
//
// Guarded rather than assumed: this file previously loaded without defer, threw
// `$ is not defined` before jQuery existed, and left both settings below
// unapplied for months. A thrown error here is invisible; a console warning at
// least survives into the driver log, and spec/features/test_harness_spec.rb
// asserts both settings actually took.
if (typeof jQuery === 'undefined') {
  console.warn('test_setup.js ran before jQuery — check the script ordering in _javascript.html.erb');
} else {
  jQuery.fx.off = true;

  // Synchronous XHR is deliberate. jQuery UI's autocomplete has no way to
  // abandon an in-flight request, so an async response can reopen a menu that
  // was already closed — after a navigation has started, which detaches the
  // node Capybara is mid-query on. With sync XHR the request completes inside
  // the keyup handler, so blurring the field (see Features::AutocompleteHelpers)
  // is a total barrier.
  jQuery.ajaxSetup({ async: false });
}
