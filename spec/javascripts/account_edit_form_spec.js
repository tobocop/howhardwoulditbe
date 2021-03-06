describe('Plink.accountEditForm', function () {

  var $container;

  beforeEach(function () {
    $('#jasmine_content').html(
      '<script type="text/handlebars-template" id="generic-error-template">' +
        '<p>{{instructions}}</p> ' +
        '<ul> {{#each errors}} ' +
        '<li class="font error">{{this}}</li> {{/each}} ' +
        '</ul> ' +
        '</script>' +
        '<div data-account-edit-form="">' +
        '<span data-display-value="first_name">John</span>' +
        '<span data-display-value="email">Jdanger@example.com</span>' +
        '<a data-toggleable-selector=".change">Change</a>' +
        '<div class="error-messages"></div>' +
        '<form class="change" action="/update/account/123" data-method="put">' +
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
      var fakejqXHR = {
        done: function (callback) {
          callback({});
          return fakejqXHR;
        },
        fail: function (callback) {

        }
      };
      spyOn($, "ajax").andReturn(fakejqXHR);

      $container.find('[name="first_name"]').val('firty');
      $container.find('[name="email"]').val('firty@example.com');

      $container.find('input[type="submit"]').click();

      expect($.ajax).toHaveBeenCalledWith('/update/account/123', { dataType: 'json', data: 'first_name=firty&email=firty%40example.com', method: 'put' });

      expect($container.find('[name="first_name"]').val()).toEqual('');
      expect($container.find('[name="email"]').val()).toEqual('');
    });

    it("updates the display values, collapses the form, and removes any errors on success", function () {

      spyOn(Plink.Notice, 'display');

      var fakeResponse = {first_name: 'firty', email: 'firty@example.com'};
      var fakejqXHR = {
        done: function (callback) {
          callback(fakeResponse);
          return fakejqXHR;
        },
        fail: function (callback) {

        }
      };
      spyOn($, "ajax").andReturn(fakejqXHR);

      $container.find('a[data-toggleable-selector]').click();
      expect($container.hasClass('expanded')).toBeTruthy();

      $container.find('.error-messages').text('a bunch of messages');

      $container.find('input[type="submit"]').click();

      expect($container.find('[data-display-value="first_name"]').text()).toEqual('firty');
      expect($container.find('[data-display-value="email"]').text()).toEqual('firty@example.com');
      expect($container.hasClass('collapsed')).toBeTruthy();
      expect($container.find('.error-messages').text().length).toEqual(0);

      expect(Plink.Notice.display).toHaveBeenCalled();
    });

    it("displays errors when they are present in the response", function () {
      var fakeResponse = {responseText: '{"error_message": "You need to fix these", "errors": {"first_name": ["you did it wrong"]}}'};
      var fakejqXHR = {
        fail: function (callback) {
          callback(fakeResponse);
        },
        done: function (callback) {
          return fakejqXHR
        }
      };
      spyOn($, "ajax").andReturn(fakejqXHR);

      $container.find('a[data-toggleable-selector]').click();
      $container.find('input[type="submit"]').click();

      expect($container.find('.error-messages').text()).toContain('You need to fix these');
      expect($container.find('.error-messages').text()).toContain('you did it wrong');
    });


  });

});
