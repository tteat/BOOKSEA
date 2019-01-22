$(document).on('turbolinks:load', function () {
  var items = $('.search-category, .search-tag');
  var counter = 0;
  var elementSaver;
  var normalize = function (text) {
    return text.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/ /g, '').toLowerCase()
  };
  var reset = function () {
    $('.search-form').val('').focus();
    items.show();
  };

  $('.search-form').on('keyup', function () {
    var search = normalize($(this).val());
    counter = 0;
    items.each(function () {
      var $this = $(this);
      var text = normalize($this.find('.custom-control-description').text());
      if (text.search(search) > -1) {
        $this.show();
        counter += 1;
        elementSaver = $this;
      } else {
        $this.hide();
      }
    });
  });

  $('.search-form').on('keydown', function (e) {
    if (e.keyCode === 13) {
      e.preventDefault();
      if (counter === 1) {
        elementSaver.find('input').prop('checked', true);
        reset();
      }
    }
  });

  $('.search-reset').on('click', reset);

  $('#comment_id').on('click',function () {
      $.ajax({ type: "POST",
          url: "add_comment",
          data: {
              bookId:$("#book_id").html(),
              content:$("#content_id").val(),
              userId:23,
              createAt:new Date()
          },
          dataType: "json",
          success: function(){

          }});
  })

    $('#joinin').on('click',function () {
          alert('加入成功！')
    })
});
