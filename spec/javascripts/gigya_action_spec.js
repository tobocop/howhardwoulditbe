describe('Plink.GigyaAction', function () {
  var element = $('<a href="http://example.com/" data-title="my-title" data-description="my-description" data-image="http://example.com/my-image.jpg"></a>')
  var action_mock = {setTitle: function() {}, setLinkBack: function() {}, setDescription: function() {}, addMediaItem: function() {}};

  beforeEach(function () {
    window.gigya = {socialize: {UserAction: {UserAction: function() {}}}};
    spyOn(gigya.socialize, 'UserAction').andReturn(action_mock);
  });

  describe('#create', function () {
    it('returns the action', function() {
      expect(Plink.GigyaAction.create(element)).toEqual(action_mock);
    });

    it('sets the title', function() {
      spyOn(action_mock, 'setTitle');
      var action = Plink.GigyaAction.create(element);
      expect(action.setTitle).toHaveBeenCalledWith('my-title');

    });

    it('sets the linkback', function() {
      spyOn(action_mock, 'setLinkBack');
      action = Plink.GigyaAction.create(element);
      expect(action.setLinkBack).toHaveBeenCalledWith('http://example.com/');
    });

    it('sets the description', function() {
      spyOn(action_mock, 'setDescription');
      var action = Plink.GigyaAction.create(element);
      expect(action.setDescription).toHaveBeenCalledWith('my-description');
    });

    it('adds the media item', function() {
      spyOn(action_mock, 'addMediaItem');
      var action = Plink.GigyaAction.create(element);
      expect(action.addMediaItem).toHaveBeenCalledWith({ type: 'image', src: 'http://example.com/my-image.jpg', href: 'http://example.com/' });
    });
  });
});

