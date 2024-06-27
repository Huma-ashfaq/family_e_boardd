class Items {
  final String img;
  final String title;
  final String subTitle;

  Items({
    required this.img,
    required this.title,
    required this.subTitle,
  });
}


List<Items> listOfItems = [

  Items(
    img : "assets/girlwithfood.json",
    title: "Streamline your meals and finances with our all-in-one app",
    subTitle: "We help you in your diet,\n and manage your budget.",
  ),
  Items(
    img : "assets/healthyfood.json",
    title: "Healthy Meal for \n Everyone",
    subTitle: "We help you to choose \n healthy meal for your diet.",
  ),
  Items(
    img : "assets/burgur.json",
    title: "Family eBoard",
    subTitle: "Let's Dine & Dime: Plan your perfect plate, track your perfect pennies",
  ),
];

