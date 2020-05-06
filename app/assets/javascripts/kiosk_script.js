$(document).ready(function() {

    $('#hours_plus').click(function() {
        let hours = parseInt($('#hours').val())

        hours ++

        $('#hours').val(hours)
        $('#hours').trigger('change')
    })

    $('#hours_minus').click(function() {
        let hours = parseInt($('#hours').val())

        hours --

        $('#hours').val(hours)
        $('#hours').trigger('change')
    })

    $('#hours').change(function() {
        $('form#check_form').submit()
    })

    $(".clickable-row").click(function() {
        window.location = $(this).data("href");
    });

})
