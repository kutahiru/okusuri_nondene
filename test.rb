class OrderService
  def confirm_order(order)
    reduce_stock(order)
  end

  # 在庫の減算処理
  # @param order [Order] 注文オブジェクト
  # @param force [Boolean] 在庫不足でも強制実行するか(デフォルト: false)
  def reduce_stock(order, force: false)
    order.items.each do |item|
      item.product.decrement!(:stock, item.quantity)
    end
  end
end
