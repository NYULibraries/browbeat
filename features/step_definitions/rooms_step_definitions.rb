Then(/my browser should resolve to (Rooms.*)$/) do |rooms_url_name|
  expect(page.current_url).to eql url_to(rooms_url_name)
end
