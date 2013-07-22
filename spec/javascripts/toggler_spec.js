describe('$.toggler', function () {
  var $trigger;

  beforeEach(function() {
    $('#jasmine_content').html(
      '<a data-toggle-selector="#toggleable" id="first-trigger">Toggle it</a>' +
      '<div id="toggleable">Booh!</div>' +
      '<a data-toggle-selector="#another-toggleable">Toggle it</a>' +
      '<div id="another-toggleable">Shizaam!</div>'
    );
    $('[data-toggle-selector]').toggler();
    $trigger = $('#first-trigger');
  });

  it("closes the target element when it is open", function () {
    expect($("#toggleable").hasClass('hidden')).toBeFalsy();

    $trigger.click();

    expect($("#toggleable").hasClass('hidden')).toBeTruthy();
    expect($("#another-toggleable").hasClass('hidden')).toBeFalsy();

    $trigger.click();

    expect($("#toggleable").hasClass('hidden')).toBeFalsy();
  });

  it('leaves the target element hidden if it initially has the hidden class', function () {
    $('#toggleable').addClass('hidden');

    expect($("#toggleable").hasClass('hidden')).toBeTruthy();

    $trigger.click();

    expect($("#toggleable").hasClass('hidden')).toBeFalsy();
  });
});

