# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class TransactionTest < Minitest::Test
  def setup
    FileUtils.rm_rf("./tmp/transaction")
    @simple_db = SimpleDB.new("./tmp/transaction", 100, 8)
  end

  def teardown
    # Do nothing
  end

  def test_transaction
    simple_db = SimpleDB.new("./tmp/transaction/transaction", 100, 8)

    transaction = simple_db.new_transaction
    transaction_number = transaction.instance_variable_get(:@transaction_number)

    block_id = BlockId.new("transaction_test", 0)

    transaction.pin(block_id)
    transaction.set_int(block_id, 0, 10, false)
    transaction.commit

    iter = simple_db.log_manager.iterator
    record1 = LogRecord.create_log_record(iter.next)
    assert_equal record1.to_s, "<COMMIT #{transaction_number}>"

    record2 = LogRecord.create_log_record(iter.next)
    assert_equal record2.to_s, "<START #{transaction_number}>"
  end

  def test_transaction2
    simple_db = SimpleDB.new("./tmp/transaction/transaction2", 100, 8)
    transaction1 = simple_db.new_transaction
    block_id = BlockId.new("testfile", 1)

    transaction1.pin(block_id)
    transaction1.set_int(block_id, 80, 1, false)
    transaction1.set_string(block_id, 40, "one", false)
    transaction1.commit

    transaction2 = simple_db.new_transaction
    transaction2.pin(block_id)
    assert_equal transaction2.get_int(block_id, 80), 1, "initial value at location 80"
    assert_equal transaction2.get_string(block_id, 40), "one", "initial value at location 40"

    transaction2.set_int(block_id, 80, 2, true)
    transaction2.set_string(block_id, 40, "one!", true)
    transaction2.commit

    transaction3 = simple_db.new_transaction
    transaction3.pin(block_id)
    assert_equal transaction3.get_int(block_id, 80), 2, "new value at location 80"
    assert_equal transaction3.get_string(block_id, 40), "one!", "new value at location 40"

    transaction3.set_int(block_id, 80, 9999, true)
    assert_equal transaction3.get_int(block_id, 80), 9999, "pre-rollback value at location 80"
    transaction3.rollback

    transaction4 = simple_db.new_transaction
    transaction4.pin(block_id)
    assert_equal transaction4.get_int(block_id, 80), 2, "post-rollback value at location 80"
    transaction4.commit
  end
end
