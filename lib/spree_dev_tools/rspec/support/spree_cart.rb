def update_cart
  if Spree.version.to_f < 4.1
    click_button 'update-button'
  else
    page.execute_script("$('form#update-cart').submit()")
  end
end

def cart_container
  if Spree.version.to_f < 4.1
    find_all("#cart-detail tbody tr:first-child").first
  else
    find_all("#cart-detail .shopping-cart-item").first
  end
end

def add_to_cart(product)
  visit spree.product_path(product)

  expect(page).to have_selector('form#add-to-cart-form')
  expect(page).to have_selector(:button, id: 'add-to-cart-button', disabled: false)

  yield if block_given?

  click_button 'add-to-cart-button'

  if Spree.version.to_f < 4.1
    wait_for_condition do
      expect(page).to have_content(Spree.t(:cart))
    end
  else
    expect(page).to have_content(Spree.t(:added_to_cart))
    visit spree.cart_path
  end
end
