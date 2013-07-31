describe('disableOnClick', function () {

  var spy;

  beforeEach(function () {

    spy = jasmine.createSpy('click spy');

    $("#jasmine_content").html('<a id="btn" href="#" data-disable-on-click="true">A Link</a>');

    $("[data-disable-on-click]").disableOnClick();

    $("#btn").click(function () {
      spy();
    });
  });

  it('disables the button after the first click', function () {
    var preventDefaultSpy = jasmine.createSpy('preventDefault');
    var stopPropSpy = jasmine.createSpy('stopPropagation');

    var mockEvent = {
      type: 'click',
      preventDefault: preventDefaultSpy,
      stopPropagation: stopPropSpy
    };

    $("#btn").trigger(mockEvent);

    expect(preventDefaultSpy).not.toHaveBeenCalled();
    expect(stopPropSpy).not.toHaveBeenCalled();

    expect($("#btn").hasClass('disabled')).toBeTruthy();
    expect($("#btn").attr('disabled')).toEqual('disabled');

    expect(spy).toHaveBeenCalled();

    $("#btn").trigger(mockEvent);
    expect(preventDefaultSpy).toHaveBeenCalled();
    expect(stopPropSpy).toHaveBeenCalled();


    $("#btn").trigger(mockEvent);
    expect(preventDefaultSpy).toHaveBeenCalled();
    expect(stopPropSpy).toHaveBeenCalled();
  });
});
