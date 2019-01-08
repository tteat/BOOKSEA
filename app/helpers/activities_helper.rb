module ActivitiesHelper
  def distinct_books(e, user = current_user)
    # Set user's book in first, other in second
    [e.book_initier, e.book_receiver].tap { |o| o.reverse! unless e.book_initier.user == user }
  end
end
