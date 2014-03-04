updateCountdown = -> 
  remaining = 139 - jQuery("#tweet_content").val().length
  jQuery(".countdown").text remaining + " characters remaining"
  jQuery(".countdown").css "color", (if (139 >= remaining >= 21) then "lightMediumGray")
  jQuery(".countdown").css "color", (if (21 > remaining >= 11) then "black")
  jQuery(".countdown").css "color", (if (11 > remaining)  then "red")
  jQuery('.countdown').addClass 'alert alert-error' if remaining < 0
  jQuery('.countdown').removeClass 'alert alert-error' if remaining > 0

jQuery ->
  updateCountdown()
  $("#tweet_content").change updateCountdown
  $("#tweet_content").keyup updateCountdown