describe('Plink.accountEditForm', function () {

  var $container;

  beforeEach(function () {
    $('#jasmine_content').html(
      '<div data-account-edit-form="">' +
        '<span data-display-value="first_name">John</span>' +
        '<span data-display-value="email">Jdanger@example.com</span>' +
        '<a data-toggleable-selector=".change">Change</a>' +
        '<form class="change" action="/update/account/123">' +
        '<input type="text" name="first_name" />' +
        '<input type="text" name="email" />' +
        '<input type="submit" value="Save" />' +
        '<a data-cancel=true>cancel</a>' +
        '</div>' +
        '</div>'
    );

    $container = $('[data-account-edit-form]');
    $container.accountEditForm();
  });

  describe('.init', function () {
    it('adds the collapsed class by default', function () {
      expect($container.hasClass('collapsed')).toBeTruthy();
    });
  });

  describe('toggling the form', function () {
    it("expands the form upon click of the trigger if the widget is collapsed", function () {
      $container.find('a[data-toggleable-selector]').click();

      expect($container.hasClass('expanded')).toBeTruthy();
    });

    it("collapses the form upon click of the trigger if the widget is expanded", function () {
      $container.find('a[data-toggleable-selector]').click();

      expect($container.hasClass('expanded')).toBeTruthy();

      $container.find('a[data-toggleable-selector]').click();

      expect($container.hasClass('expanded')).toBeFalsy();
      expect($container.hasClass('collapsed')).toBeTruthy();
    });

    it("collapses the form when cancel is clicked", function () {
      $container.find('a[data-toggleable-selector]').click();

      expect($container.hasClass('expanded')).toBeTruthy();

      $container.find('[data-cancel]').click();

      expect($container.hasClass('collapsed')).toBeTruthy();
    });
  });

  describe('submitting the form', function () {
    it("submits the form", function () {
      var fakejqXHR = {done: function (callback) {
        callback({})
      }};
      spyOn($, "ajax").andReturn(fakejqXHR);

      $container.find('[name="first_name"]').val('firty');
      $container.find('[name="email"]').val('firty@example.com');

      $container.find('input[type="submit"]').click();

      expect($.ajax).toHaveBeenCalledWith('/update/account/123', { data: 'first_name=firty&email=firty%40example.com', method: 'put' });
    });

    it("updates the display values and collapses the form on success", function () {
      var fakeResponse = {first_name: 'firty', email: 'firty@example.com'};
      var fakejqXHR = {done: function (callback) {
        callback(fakeResponse);
      }};
      spyOn($, "ajax").andReturn(fakejqXHR);

      $container.find('a[data-toggleable-selector]').click();
      expect($container.hasClass('expanded')).toBeTruthy();

      $container.find('input[type="submit"]').click();

      expect($container.find('[data-display-value="first_name"]').text()).toEqual('firty');
      expect($container.find('[data-display-value="email"]').text()).toEqual('firty@example.com');
      expect($container.hasClass('collapsed')).toBeTruthy();
    });


  });

});
