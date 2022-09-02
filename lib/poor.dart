import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String bikeFrame =
    'https://masoncycles.cc/images/000/003/820/large/Vela_resolution_frame_views_front_lighter.jpg?1625580237';
const String wheels =
    'https://static.elite-wheels.com/wp-content/uploads/2021/12/Drive-50D-disc-brake-Road-carbon-spoke-wheelset-1-500x333.webp';
const String setGroup =
    'https://images.immediate.co.uk/production/volatile/sites/21/2019/03/01_shimano_deore_t6000_touring_groupset-1498235516737-1vf8qf21c4g04-1000-100-2909866-e1578060720296.jpg?quality=90&resize=768,574';

Cart cart = Cart();

void main() {
  runApp(
    const MaterialApp(
      home: BikeHub(),
    ),
  );
}

class BikeHub extends StatelessWidget {
  const BikeHub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          primarySwatch: Colors.orange, scaffoldBackgroundColor: Colors.black),
      child: Builder(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String searchString;

  @override
  void initState() {
    searchString = '';
    super.initState();
  }

  void setSearchString(String value) => setState(() {
        searchString = value;
      });

  @override
  Widget build(BuildContext context) {
    var listViewPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 24);
    List<Widget> searchResultTiles = [];
    if (searchString.isNotEmpty) {
      searchResultTiles = products
          .where(
              (p) => p.name.toLowerCase().contains(searchString.toLowerCase()))
          .map(
            (p) => ProductTile(product: p),
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          onChanged: setSearchString,
        ),
        actions: const [
          CartAppBarAction(),
        ],
      ),
      body: searchString.isNotEmpty
          ? GridView.count(
              padding: listViewPadding,
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: .78,
              children: searchResultTiles,
            )
          : ListView(
              padding: listViewPadding,
              children: [
                const Center(
                  child: Image(
                    image: AssetImage(
                      'assets/images/logo.png',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CategoryTile(
                    imageUrl: bikeFrame,
                    category: frameSet,
                    imageAlignment: Alignment.topCenter),
                const SizedBox(height: 16),
                CategoryTile(
                  imageUrl: setGroup,
                  category: groupSet,
                  imageAlignment: Alignment.topCenter,
                ),
                const SizedBox(height: 16),
                CategoryTile(
                  imageUrl: wheels,
                  category: wheelSet,
                ),
              ],
            ),
    );
  }
}

class CartAppBarAction extends StatefulWidget {
  const CartAppBarAction({Key? key}) : super(key: key);

  @override
  _CartAppBarActionState createState() => _CartAppBarActionState();
}

class _CartAppBarActionState extends State<CartAppBarAction> {
  @override
  void initState() {
    cart.addListener(blankSetState);
    super.initState();
  }

  @override
  void dispose() {
    cart.removeListener(blankSetState);
    super.dispose();
  }

  void blankSetState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.shopping_cart,
          ),
          if (cart.itemsInCart.isNotEmpty)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: Center(
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        cart.itemsInCart.length.toString(),
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: () => _pushScreen(
        context: context,
        screen: const CartScreen(),
      ),
    );
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({required this.product, Key? key}) : super(key: key);
  final Product product;

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Product get product => widget.product;
  String? selectedImageUrl;
  String? selectedSize;

  @override
  void initState() {
    selectedImageUrl = product.imageUrls.first;
    selectedSize = product.sizes?.first;
    super.initState();
  }

  void setSelectedImageUrl(String url) {
    setState(() {
      selectedImageUrl = url;
    });
  }

  void setSelectedSize(String size) {
    setState(() {
      selectedSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> imagePreviews = product.imageUrls
        .map(
          (url) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () => setSelectedImageUrl(url),
              child: Container(
                height: 50,
                width: 50,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: selectedImageUrl == url
                      ? Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1.75)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  url,
                ),
              ),
            ),
          ),
        )
        .toList();

    List<Widget> sizeSelectionWidgets = product.sizes
            ?.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setSelectedSize(s);
                  },
                  child: Container(
                    height: 42,
                    width: 38,
                    decoration: BoxDecoration(
                      color: selectedSize == s
                          ? Theme.of(context).backgroundColor
                          : Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.25,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        s,
                        style: Theme.of(context).textTheme.caption!.copyWith(
                            color: selectedSize == s ? Colors.black : null),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: const [
          CartAppBarAction(),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * .35,
            color: kGreyBackground,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.network(
                    selectedImageUrl!,
                    fit: BoxFit.cover,
                    color: kGreyBackground,
                    colorBlendMode: BlendMode.multiply,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imagePreviews,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Colors.orange,
                          )),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    "\₱" + product.cost.toString(),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description ??
                        "The T1500 is for the professional racer or the cycling enthusiast who wants to get where they're going...fast. Designed from the ground up with speed in mind and brought to fruition the perfect blend of aerodynamics, stiffness, lightweight, and comfort. ",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(height: 1.5, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  if (sizeSelectionWidgets.isNotEmpty) ...[
                    Text(
                      "Size",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      //Putang ina
                      children: sizeSelectionWidgets,
                    ),
                  ],
                  const Spacer(),
                  Center(
                    child: CallToActionButton(
                      onPressed: () => cart.add(
                        OrderItem(
                          product: product,
                          selectedSize: selectedSize,
                        ),
                      ),
                      labelText: "Add to Cart",
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CallToActionButton extends StatelessWidget {
  const CallToActionButton(
      {required this.onPressed,
      required this.labelText,
      this.minSize = const Size(266, 45),
      Key? key})
      : super(key: key);
  final Function onPressed;
  final String labelText;
  final Size minSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed as void Function()?,
      style: ElevatedButton.styleFrom(
        minimumSize: minSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        labelText,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({required this.category, Key? key}) : super(key: key);
  final Category category;

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

enum Filters { popular, recent, sale }

class _CategoryScreenState extends State<CategoryScreen> {
  Category get category => widget.category;
  Filters filterValue = Filters.popular;
  String? selection;
  late List<Product> _products;

  @override
  void initState() {
    selection = category.selections.first;
    _products = products.where((p) => p.category == category).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ProductRow> productRows = category.selections
        .map((s) => ProductRow(
              productType: s,
              products: _products
                  .where((p) => p.productType.toLowerCase() == s.toLowerCase())
                  .toList(),
            ))
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(category.title),
        actions: const [
          CartAppBarAction(),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 18),
        itemCount: productRows.length,
        itemBuilder: (_, index) => productRows[index],
        separatorBuilder: (_, index) => const SizedBox(
          height: 18,
        ),
      ),
    );
  }
}

class ProductRow extends StatelessWidget {
  const ProductRow(
      {required this.products, required this.productType, Key? key})
      : super(key: key);
  final String productType;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    List<ProductTile> _productTiles =
        products.map((p) => ProductTile(product: p)).toList();

    return _productTiles.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                ),
                child: Text(
                  productType,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 205,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _productTiles.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => _productTiles[index],
                  separatorBuilder: (_, index) => const SizedBox(
                    width: 24,
                  ),
                ),
              ),
            ],
          );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({required this.product, Key? key}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        _pushScreen(
          context: context,
          screen: ProductScreen(product: product),
        );
      },
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(product: product),
            const SizedBox(
              height: 8,
            ),
            Text(
              product.name,
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            const Spacer(),
            Text(
              "\₱${product.cost.toString()}",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: .95,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: kGreyBackground,
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.network(
          product.imageUrls.first,
          loadingBuilder: (_, child, loadingProgress) => loadingProgress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
          color: kGreyBackground,
          colorBlendMode: BlendMode.multiply,
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    cart.addListener(updateState);
  }

  @override
  void dispose() {
    cart.removeListener(updateState);
    super.dispose();
  }

  void updateState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    List<Widget> orderItemRows = cart.itemsInCart
        .map(
          (item) => Row(
            children: [
              SizedBox(
                width: 125,
                child: ProductImage(
                  product: item.product,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "\₱" + item.product.cost.toString(),
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => cart.remove(item),
                color: Colors.black,
              )
            ],
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text("Cart"),
            Text(
              cart.itemsInCart.length.toString() + " items",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          if (orderItemRows.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                itemCount: orderItemRows.length,
                itemBuilder: (_, index) => orderItemRows[index],
                separatorBuilder: (_, index) => const SizedBox(
                  height: 16,
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text("Your cart is empty"),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Text(
                      "\₱" + cart.totalCost.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                CallToActionButton(
                  onPressed: () {},
                  labelText: "Check Out",
                  minSize: const Size(220, 45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile(
      {required this.category,
      required this.imageUrl,
      this.imageAlignment = Alignment.center,
      Key? key})
      : super(key: key);
  final String imageUrl;
  final Category category;

  final Alignment imageAlignment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pushScreen(
        context: context,
        screen: CategoryScreen(
          category: category,
        ),
      ),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              color: kGreyBackground,
              colorBlendMode: BlendMode.darken,
              alignment: imageAlignment,
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                category.title.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(color: Colors.white, fontFamily: 'RobotoMono'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({required this.onChanged, Key? key}) : super(key: key);

  final Function(String) onChanged;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        onChanged: widget.onChanged,
        controller: _textEditingController,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              kIsWeb ? const EdgeInsets.only(top: 10) : EdgeInsets.zero,
          prefixIconConstraints: const BoxConstraints(
            minHeight: 36,
            minWidth: 36,
          ),
          prefixIcon: const Icon(
            Icons.search,
          ),
          hintText: "Look for a product",
          suffixIconConstraints: const BoxConstraints(
            minHeight: 36,
            minWidth: 36,
          ),
          suffixIcon: IconButton(
            constraints: const BoxConstraints(
              minHeight: 36,
              minWidth: 36,
            ),
            splashRadius: 24,
            icon: const Icon(
              Icons.clear,
            ),
            onPressed: () {
              _textEditingController.clear();
              widget.onChanged(_textEditingController.text);
              FocusScope.of(context).unfocus();
            },
          ),
        ),
      ),
    );
  }
}

class Category {
  final String title;
  final List<String> selections;

  Category({required this.title, required this.selections});
}

void _pushScreen({required BuildContext context, required Widget screen}) {
  ThemeData themeData = Theme.of(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Theme(data: themeData, child: screen),
    ),
  );
}

class Product {
  final String name;
  final List<String> imageUrls;
  final double cost;
  final String? description;
  final List<String>? sizes;

  final Category category;

  final String productType;

  Product(
      {required this.name,
      required this.imageUrls,
      required this.cost,
      this.description,
      this.sizes,
      required this.category,
      required this.productType});
}

class Cart with ChangeNotifier {
  List<OrderItem> itemsInCart = [];

  double get totalCost {
    double total = 0;
    for (var item in itemsInCart) {
      total += item.product.cost;
    }
    return total;
  }

  void add(OrderItem orderItem) {
    itemsInCart.add(orderItem);
    notifyListeners();
  }

  void remove(OrderItem orderItem) {
    itemsInCart.remove(orderItem);
    notifyListeners();
  }
}

class OrderItem {
  Product product;
  String? selectedSize;
  String? selectedColor;

  OrderItem({required this.product, this.selectedSize, this.selectedColor});
}

// BIKE HUB CATEGORY
Category frameSet = Category(title: "Frameset", selections: [
  "Aero Frame",
  "Endurance",
  "Time Trial",
]);
Category groupSet = Category(title: "Groupset", selections: [
  "Roadbike",
  "Mountainbike",
]);
Category wheelSet = Category(title: "Wheelset", selections: [
  "Roadbike",
  "Mountainbike",
]);

//Shop Items

final kGreyBackground = Colors.grey[200];
List<Product> products = [
  Product(
      name: "Trek Madone SLR",
      imageUrls: [
        "https://trek.scene7.com/is/image/TrekBicycleProducts/MadoneSLRDiscFrameset_22_33044_B_Primary?wid=1200",
        "https://trek.scene7.com/is/image/TrekBicycleProducts/MadoneSLRFrameset_20_30191_A_Primary?&cache=on,on&wid=1920&hei=1440",
        "https://trek.scene7.com/is/image/TrekBicycleProducts/1476100_2018_A_1_Madone_9_RSL_Frameset?&cache=on,on&wid=1920&hei=1440",
        "https://trek.scene7.com/is/image/TrekBicycleProducts/MadoneSLDiscFrameset_22_35084_A_Primary?wid=1200"
      ],
      cost: 42000.00,
      category: frameSet,
      productType: "aero frame",
      sizes: ["46", "47", "48", "50"]),
  Product(
      name: "Mosso 739 TCA",
      imageUrls: [
        "https://cf.shopee.ph/file/fb7447bc83d86a0db494ba2e5e5c15ff",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZ6bQ3t17hQfVG_8dZnY4GuPeuauH0ywdOnd76TxeyzyCIVbfDwaQ9eN7wmLu5k5kMH6I&usqp=CAU",
        "http://www.fusioncycle.com/imagbes/MOSO-737TCA-BWR.jpg",
        "https://ae01.alicdn.com/kf/H0fa966021d1b4376867b2e6f1c33f32eo.jpg"
      ],
      cost: 35000.00,
      category: frameSet,
      productType: "aero frame",
      sizes: ["46", "47", "48", "50"]),
  Product(
      name: "Triaero Full Carbon",
      imageUrls: [
        "https://ae01.alicdn.com/kf/H734a0fe027394fdcb5221e98f8d467ffv/2019-professional-racing-AERO-frame-carbon-road-disc-brake-frame-with-Black-and-white-glossy.jpg_Q90.jpg_.webp",
        "https://ae01.alicdn.com/kf/HTB1eNlfaKL2gK0jSZFmq6A7iXXaD/2020-new-model-carbon-road-bicycle-frame-disc-brake-BB86-bike-frame-with-aero-handlebar.jpg_Q90.jpg_.webp",
      ],
      cost: 24000.00,
      category: frameSet,
      productType: "aero frame",
      sizes: ["46", "47", "48", "50"]),
  Product(
      name: "Test 4 ",
      imageUrls: [
        "https://cdn.shopify.com/s/files/1/0576/4562/9590/products/2021_T1500_GGR_45_950x.png?v=1651575488",
        "https://cdn.shopify.com/s/files/1/0576/4562/9590/products/2021_T1500_GGR_Side_950x.png?v=1651575488",
        "https://cdn.shopify.com/s/files/1/0576/4562/9590/products/2021_T1500_GWH_45_950x.png?v=1651575488",
        "https://cdn.shopify.com/s/files/1/0576/4562/9590/products/Turb_950x.png?v=1651575488"
      ],
      cost: 2499.00,
      category: frameSet,
      productType: "aero frame",
      sizes: ["46", "47", "48", "50"]),
  Product(
      name: "T1500 Aero Frameset",
      imageUrls: [
        "https://cdn.shopify.com/s/files/1/0576/4562/9590/products/2021_T1500_GGR_45_950x.png?v=1651575488",
        "https://cdn.shopify.com/s/files/1/0576/4562/9590/products/2021_T1500_GGR_Side_950x.png?v=1651575488",
        "https://cdn.shopify.com/s/files/1/0576/4562/9590/products/2021_T1500_GWH_45_950x.png?v=1651575488",
        "https://cdn.shopify.com/s/files/1/0576/4562/9590/products/Turb_950x.png?v=1651575488"
      ],
      cost: 2499.00,
      category: frameSet,
      productType: "aero frame",
      sizes: ["46", "47", "48", "50"]),
  Product(
    name: "Test 1 Roadmachine",
    imageUrls: [
      "http://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072953/BMC-Roadmachine-carbon-endurance-road-bike-2020-43.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072922/BMC-Roadmachine-carbon-endurance-road-bike-fork-1.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072920/BMC-Roadmachine-carbon-endurance-road-bike-2020-24.jpg",
    ],
    cost: 2499.99,
    category: frameSet,
    productType: "endurance",
    sizes: ["46", "47", "48", "49", "51"],
  ),
  Product(
    name: "Test 2 Roadmachine",
    imageUrls: [
      "http://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072953/BMC-Roadmachine-carbon-endurance-road-bike-2020-43.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072922/BMC-Roadmachine-carbon-endurance-road-bike-fork-1.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072920/BMC-Roadmachine-carbon-endurance-road-bike-2020-24.jpg",
    ],
    cost: 2499.99,
    category: frameSet,
    productType: "endurance",
    sizes: ["46", "47", "48", "49", "51"],
  ),
  Product(
    name: "Test 3 Roadmachine",
    imageUrls: [
      "http://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072953/BMC-Roadmachine-carbon-endurance-road-bike-2020-43.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072922/BMC-Roadmachine-carbon-endurance-road-bike-fork-1.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072920/BMC-Roadmachine-carbon-endurance-road-bike-2020-24.jpg",
    ],
    cost: 2499.99,
    category: frameSet,
    productType: "endurance",
    sizes: ["46", "47", "48", "49", "51"],
  ),
  Product(
    name: "BMC Roadmachine",
    imageUrls: [
      "http://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072953/BMC-Roadmachine-carbon-endurance-road-bike-2020-43.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072922/BMC-Roadmachine-carbon-endurance-road-bike-fork-1.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2019/06/02072920/BMC-Roadmachine-carbon-endurance-road-bike-2020-24.jpg",
    ],
    cost: 2499.99,
    category: frameSet,
    productType: "endurance",
    sizes: ["46", "47", "48", "49", "51"],
  ),
  Product(
    name: "Test1 Time Warp TT",
    imageUrls: [
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120235/Merida-Time-Warp-TT-disc-brake-time-trial-bike_frame-kit.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120211/Merida-Time-Warp-TT-disc-brake-time-trial-bike_frame-kit-angled.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120207/Merida-Time-Warp-TT-disc-brake-time-trial-bike_black-frameset-kit.jpg",
    ],
    cost: 2788.99,
    category: frameSet,
    productType: "time trial",
    sizes: ["44", "46", "48", "50", "51"],
  ),
  Product(
    name: "Test2 Time Warp TT",
    imageUrls: [
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120235/Merida-Time-Warp-TT-disc-brake-time-trial-bike_frame-kit.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120211/Merida-Time-Warp-TT-disc-brake-time-trial-bike_frame-kit-angled.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120207/Merida-Time-Warp-TT-disc-brake-time-trial-bike_black-frameset-kit.jpg",
    ],
    cost: 2788.99,
    category: frameSet,
    productType: "time trial",
    sizes: ["44", "46", "48", "50", "51"],
  ),
  Product(
    name: "Test3 Time Warp TT",
    imageUrls: [
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120235/Merida-Time-Warp-TT-disc-brake-time-trial-bike_frame-kit.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120211/Merida-Time-Warp-TT-disc-brake-time-trial-bike_frame-kit-angled.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120207/Merida-Time-Warp-TT-disc-brake-time-trial-bike_black-frameset-kit.jpg",
    ],
    cost: 2788.99,
    category: frameSet,
    productType: "time trial",
    sizes: ["44", "46", "48", "50", "51"],
  ),
  Product(
    name: "Test4 Time Warp TT",
    imageUrls: [
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120235/Merida-Time-Warp-TT-disc-brake-time-trial-bike_frame-kit.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120211/Merida-Time-Warp-TT-disc-brake-time-trial-bike_frame-kit-angled.jpg",
      "https://s3.amazonaws.com/www.bikerumor.com/wp-content/uploads/2022/03/30120207/Merida-Time-Warp-TT-disc-brake-time-trial-bike_black-frameset-kit.jpg",
    ],
    cost: 2788.99,
    category: frameSet,
    productType: "time trial",
    sizes: ["44", "46", "48", "50", "51"],
  ),
  Product(
    name: "Claris GS 8 Speed",
    imageUrls: [
      "https://cdn.road.cc/sites/default/files/styles/main_width/public/claris-r2000-groupset.jpg",
    ],
    cost: 8000.00,
    category: groupSet,
    productType: "roadbike",
  ),
  Product(
    name: "XTR GS 12 Speed",
    imageUrls: [
      "https://marketplacer.imgix.net/NC/pEHQi6gYxSs7eOK6qgNOci0L8.jpg?auto=format&fm=pjpg&fit=max&w=1000&h=1000&s=6c5497e5ed776354744cb0fe1cbe1d6d",
    ],
    cost: 14999.99,
    category: groupSet,
    productType: "mountainbike",
  ),
  Product(
    name: "Claris GS 8 Speed",
    imageUrls: [
      "https://cdn.road.cc/sites/default/files/styles/main_width/public/claris-r2000-groupset.jpg",
    ],
    cost: 8000.00,
    category: groupSet,
    productType: "roadbike",
  ),
  Product(
    name: "XTR GS 12 Speed",
    imageUrls: [
      "https://marketplacer.imgix.net/NC/pEHQi6gYxSs7eOK6qgNOci0L8.jpg?auto=format&fm=pjpg&fit=max&w=1000&h=1000&s=6c5497e5ed776354744cb0fe1cbe1d6d",
    ],
    cost: 14999.99,
    category: groupSet,
    productType: "mountainbike",
  ),
  Product(
    name: "Claris GS 8 Speed",
    imageUrls: [
      "https://cdn.road.cc/sites/default/files/styles/main_width/public/claris-r2000-groupset.jpg",
    ],
    cost: 8000.00,
    category: groupSet,
    productType: "roadbike",
  ),
  Product(
    name: "XTR GS 12 Speed",
    imageUrls: [
      "https://marketplacer.imgix.net/NC/pEHQi6gYxSs7eOK6qgNOci0L8.jpg?auto=format&fm=pjpg&fit=max&w=1000&h=1000&s=6c5497e5ed776354744cb0fe1cbe1d6d",
    ],
    cost: 14999.99,
    category: groupSet,
    productType: "mountainbike",
  ),
  Product(
    name: "Claris GS 8 Speed",
    imageUrls: [
      "https://cdn.road.cc/sites/default/files/styles/main_width/public/claris-r2000-groupset.jpg",
    ],
    cost: 8000.00,
    category: groupSet,
    productType: "roadbike",
  ),
  Product(
    name: "XTR GS 12 Speed",
    imageUrls: [
      "https://marketplacer.imgix.net/NC/pEHQi6gYxSs7eOK6qgNOci0L8.jpg?auto=format&fm=pjpg&fit=max&w=1000&h=1000&s=6c5497e5ed776354744cb0fe1cbe1d6d",
    ],
    cost: 14999.99,
    category: groupSet,
    productType: "mountainbike",
  ),
  Product(
    name: "Enve SES 7.8 Clincher",
    imageUrls: [
      "https://www.sefiles.net/images/library/zoom/enve-ses-7.8-700c-clincher-envec-wheelset-315079-13.jpg",
    ],
    cost: 24000.00,
    category: wheelSet,
    productType: "roadbike",
  ),
  Product(
    name: "DT Swiss 29er Carbon",
    imageUrls: [
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKGRwoUm3TodLsEpYRTE80BLXgOHCH7H9vlN7Md4dmtnY3JlVa7j6bDoMiaxu7Ec0Diks&usqp=CAU",
    ],
    cost: 40000.00,
    category: wheelSet,
    productType: "mountainbike",
  ),
  Product(
    name: "Enve SES 7.8 Clincher",
    imageUrls: [
      "https://www.sefiles.net/images/library/zoom/enve-ses-7.8-700c-clincher-envec-wheelset-315079-13.jpg",
    ],
    cost: 24000.00,
    category: wheelSet,
    productType: "roadbike",
  ),
  Product(
    name: "DT Swiss 29er Carbon",
    imageUrls: [
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKGRwoUm3TodLsEpYRTE80BLXgOHCH7H9vlN7Md4dmtnY3JlVa7j6bDoMiaxu7Ec0Diks&usqp=CAU",
    ],
    cost: 40000.00,
    category: wheelSet,
    productType: "mountainbike",
  ),
  Product(
    name: "Enve SES 7.8 Clincher",
    imageUrls: [
      "https://www.sefiles.net/images/library/zoom/enve-ses-7.8-700c-clincher-envec-wheelset-315079-13.jpg",
    ],
    cost: 24000.00,
    category: wheelSet,
    productType: "roadbike",
  ),
  Product(
    name: "DT Swiss 29er Carbon",
    imageUrls: [
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKGRwoUm3TodLsEpYRTE80BLXgOHCH7H9vlN7Md4dmtnY3JlVa7j6bDoMiaxu7Ec0Diks&usqp=CAU",
    ],
    cost: 40000.00,
    category: wheelSet,
    productType: "mountainbike",
  ),
  Product(
    name: "Enve SES 7.8 Clincher",
    imageUrls: [
      "https://www.sefiles.net/images/library/zoom/enve-ses-7.8-700c-clincher-envec-wheelset-315079-13.jpg",
    ],
    cost: 24000.00,
    category: wheelSet,
    productType: "roadbike",
  ),
  Product(
    name: "DT Swiss 29er Carbon",
    imageUrls: [
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKGRwoUm3TodLsEpYRTE80BLXgOHCH7H9vlN7Md4dmtnY3JlVa7j6bDoMiaxu7Ec0Diks&usqp=CAU",
    ],
    cost: 40000.00,
    category: wheelSet,
    productType: "mountainbike",
  ),
  Product(
    name: "Enve SES 7.8 Clincher",
    imageUrls: [
      "https://www.sefiles.net/images/library/zoom/enve-ses-7.8-700c-clincher-envec-wheelset-315079-13.jpg",
    ],
    cost: 24000.00,
    category: wheelSet,
    productType: "roadbike",
  ),
  Product(
    name: "DT Swiss 29er Carbon",
    imageUrls: [
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKGRwoUm3TodLsEpYRTE80BLXgOHCH7H9vlN7Md4dmtnY3JlVa7j6bDoMiaxu7Ec0Diks&usqp=CAU",
    ],
    cost: 40000.00,
    category: wheelSet,
    productType: "mountainbike",
  ),
];
