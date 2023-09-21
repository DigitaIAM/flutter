import 'package:nae/schema/schema.dart';

// https://material.io/design/usability/accessibility.html#layout-typography
const double cMinInteractiveDimension = 48.0;

const int cAnimationDuration = 500;

const int cDebounceUpdate = 500; // .5 second

const double cBorderRadius = 2;

const double cMobileDialogPadding = 12;

const double cDrawerToolsWidth = 50;
const double cDrawerWidthMobile = 272;
const double cDrawerWidthDesktop = 210;
const double cBarHeight = 50;

const double cTableColumnGap = 16;

// JavaScript does not support integers, use it detect web environment
const bool cIsWeb = identical(0, 0.0);

const Field fName = Field(cName, StringType());
const Field fDate = Field(cDate, DateType());
const Field fWeight = Field('weight', NumberType());

const Field fCounterparty = Field(
  cCounterparty,
  ReferenceType([
    cCounterparty
  ], fields: [
    Field('tin', StringType()),
    Field(cName, StringType()),
  ]),
);

const Field fStorage = Field(cStorage, ReferenceType([cWarehouse, cStorage]));
const Field fArea = Field(cArea, ReferenceType([cProduction, cArea]));

const Field fFrom = Field(cFrom, ReferenceType([cWarehouse, cStorage]));
const Field fInto = Field(cInto, ReferenceType([cWarehouse, cStorage]));

const Field fOperator = Field(cOperator, ReferenceType([cPerson]));
const Field fControl = Field(cControl, ReferenceType([cPerson]));

const Field fProduct = Field(cProduct, ReferenceType([cProduct]));

const Field fGoods = Field(
  cGoods,
  ReferenceType([
    cGoods
  ], fields: [
    fName,
    fUom,
    // TODO add relation between `uom` <> `qty.uom`
  ]),
);
const Field fCategory = Field(cCategory, ReferenceType([cGoods, cCategory]));
const Field fBatch = Field(cBatch, StringType(), path: [cBatch, cBarcode]);
const Field fQtySingle = Field(cQty, NumberType(), path: [cQty]);
const Field fQty = Field(cQty, NumberType(), path: [cQty, cNumber]);
const Field fUomAtGoods = Field(cUom, ReferenceType([cUom]), path: [cGoods, cUom]);
const Field fUomAtQty = Field(cUom, ReferenceType([cUom]), path: [cQty, cUom]);
const Field fUom = Field(cUom, ReferenceType([cUom]));

const Field fType = Field(cType, ReferenceType([cType]));

// TODO add relation between `qty`, `price` & `cost`
// cost = qty * price
// price = cost / qty
// qty = cost / price
const Field fPrice = Field(cPrice, NumberType());
const Field fCost = Field(cCost, NumberType());

const String cStatus = '_status';
const String cDocument = 'document';
const String cOrder = 'order';
const String cGoods = 'goods';
const String cDate = 'date';
const String cQty = 'qty';
const String cCost = 'cost';
const String cPrice = 'price';
const String cId = '_id';
const String cUuid = '_uuid';
const String cUom = 'uom';
const String cStorage = 'storage';
const String cPrinter = 'printer';
const String cCounterparty = 'counterparty';
const String cName = 'name';
const String cWarehouse = 'warehouse';
const String cArea = 'area';
const String cProduction = 'production';
const String cFrom = 'from';
const String cInto = 'into';
const String cProduct = 'product';
const String cPerson = 'person';
const String cOperator = 'operator';
const String cControl = 'control';
const String cCategory = 'category';
const String cBatch = 'batch';
const String cBarcode = 'barcode';
const String cNumber = 'number';
const String cType = 'type';
