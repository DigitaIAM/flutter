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

const Field fName = Field('name', StringType());
const Field fDate = Field('date', DateType());

const Field fCounterparty = Field(
  'counterparty',
  ReferenceType([
    'counterparty'
  ], fields: [
    Field('tin', StringType()),
    Field('name', StringType()),
  ]),
);

const Field fStorage = Field('storage', ReferenceType(['warehouse', 'storage']));
const Field fArea = Field('area', ReferenceType(['production', 'area']));

const Field fFrom = Field('from', ReferenceType(['warehouse', 'storage']));
const Field fInto = Field('into', ReferenceType(['warehouse', 'storage']));

const Field fOperator = Field("operator", ReferenceType(['person']));
const Field fControl = Field("control", ReferenceType(['person']));

const Field fProduct = Field("product", ReferenceType(['product']));

const Field fGoods = Field(
  'goods',
  ReferenceType([
    'goods'
  ], fields: [
    fName,
    fUom,
    // TODO add relation between `uom` <> `qty.uom`
  ]),
);
const Field fBatch = Field('batch', StringType(), path: ['batch', 'barcode']);
const Field fQtySingle = Field('qty', NumberType(), path: ['qty']);
const Field fQty = Field('qty', NumberType(), path: ['qty', 'number']);
const Field fUomAtGoods = Field('uom', ReferenceType(['uom']), path: ['goods', 'uom']);
const Field fUomAtQty = Field('uom', ReferenceType(['uom']), path: ['qty', 'uom']);
const Field fUom = Field('uom', ReferenceType(['uom']));

const Field fType = Field('type', ReferenceType(['type']));

// TODO add relation between `qty`, `price` & `cost`
// cost = qty * price
// price = cost / qty
// qty = cost / price
const Field fPrice = Field('price', NumberType());
const Field fCost = Field('cost', NumberType());
