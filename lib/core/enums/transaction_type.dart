enum TransactionType {
  cashIn,
  cashOut;

  String get dbValue {
    switch (this) {
      case TransactionType.cashIn:
        return 'CASH_IN';
      case TransactionType.cashOut:
        return 'CASH_OUT';
    }
  }

  static TransactionType fromDbValue(String value) {
    if (value == 'CASH_IN') {
      return TransactionType.cashIn;
    } else if (value == 'CASH_OUT') {
      return TransactionType.cashOut;
    }
    return TransactionType.cashIn;
  }

  String get label {
    switch (this) {
      case TransactionType.cashIn:
        return 'Cash In';
      case TransactionType.cashOut:
        return 'Cash Out';
    }
  }
}
