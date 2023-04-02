using Firebase.Storage;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Mvc;
using ProjectFood.Helper;
using ProjectFood.Models;
using static System.Net.Mime.MediaTypeNames;
using System.IO;
using Firebase.Auth;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace ProjectFood.Controllers
{
    public class UpdateFoodController : Controller
    {
        private IWebHostEnvironment _appEnvironment;

        public UpdateFoodController(IWebHostEnvironment appEnvironment)
        {
            _appEnvironment = appEnvironment;
        }

        private async Task<List<Dictionary<string, object>>> GetCategories()
        {
            List<Dictionary<string, object>> _Categories = new List<Dictionary<string, object>>();
            FirestoreDb db = FirestoreDb.Create("foodproject-xxxx");
            CollectionReference usersRef = db.Collection("category");
            QuerySnapshot snapshot = await usersRef.GetSnapshotAsync();

            if (snapshot.Documents.Count > 0)
            {
                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    Dictionary<string, object> documentDictionary = document.ToDictionary();
                    _Categories.Add(documentDictionary);
                }
            }
            return _Categories;
        }

        private async Task<List<SelectListItem>> GetCategoriesItems(string id)
        {
            var categories = await GetCategories();

            List<SelectListItem> listItems = categories.Select(pair => new SelectListItem
            {
                Text = pair["category"].ToString(),
                Value = pair["id"].ToString(),
                Selected = pair["id"].ToString() == id
            }).ToList();

            return listItems;
        }

        [HttpGet]
        public async Task<IActionResult> Index(string id)
        {

            ImageUrlData.dictData.Clear();

            if (id == null) return Redirect("/Home/Items/");

            FirestoreDb db = FirestoreDb.Create("foodproject-xxxx");
            DocumentReference docRef = db.Collection("food").Document(id);
            DocumentSnapshot snapshot = await docRef.GetSnapshotAsync();

            if (!snapshot.Exists)
            {
                return Redirect("/Home/Items/");
            }

            Dictionary<string, object> food = snapshot.ToDictionary();

            FoodModel foodModel = new FoodModel();
            foodModel.Name = food["name"] as string;
            foodModel.Description = food["description"] as string;
            foodModel.Price = Convert.ToInt32(food["price"]);
            foodModel.Weight = Convert.ToInt32(food["weight"]);
            foodModel.id = food["id"] as string;
            foodModel.previewImage = food["previewImage"] as string;
            foodModel.category = food["category"] as string;
            foodModel.Categories = await GetCategoriesItems(foodModel.category);


            var urlList = (food["urlImage"] as List<object>).Cast<string>().ToList();


            if (urlList.Count != 0)
            {
                foodModel.urlList = urlList;
            }

            foreach(var url in urlList)
            {
                string decodeUrlString = DecodeUrlString(url);

                int indexSlash = decodeUrlString.LastIndexOf('/');
                int indexQuestion = decodeUrlString.IndexOf("?");
                int endLength = decodeUrlString.Substring(indexSlash).Length - decodeUrlString.Substring(indexQuestion).Length;
                string nameImg = decodeUrlString.Substring(indexSlash + 1, endLength - 1);
                ImageUrlData.dictData.Add(nameImg, url);
            }

            return View(foodModel);
        }

        private static string DecodeUrlString(string url)
        {
            string newUrl;
            while ((newUrl = Uri.UnescapeDataString(url)) != url)
                url = newUrl;
            return newUrl;
        }


        [HttpPost]
        public async Task<IActionResult> Index(FoodModel foodModel)
        {

            var authProvider = new FirebaseAuthProvider(new FirebaseConfig("config"));
            var auth = await authProvider.SignInWithEmailAndPasswordAsync("email", "pass");


            foodModel.Categories = await GetCategoriesItems(foodModel.category);
            if (!ModelState.IsValid) return View(foodModel);
            

            var urlList = foodModel.urlList;

            if (urlList != null)
            {
                List<string> missUrl = new List<string>();

                foreach (KeyValuePair<string, string> nameUrl in ImageUrlData.dictData)
                {
                    if (!urlList.Any(x => x == nameUrl.Value))
                    {
                        missUrl.Add(nameUrl.Key);
                    }
                }

                foreach (var el in missUrl)
                {
                    try
                    {
                        var task = new FirebaseStorage("foodproject-xxxx.appspot.com", new FirebaseStorageOptions
                        {
                            AuthTokenAsyncFactory = () => Task.FromResult(auth.FirebaseToken),
                            ThrowOnCancel = true,
                        })
                        .Child("FoodImage")
                        .Child(foodModel.id)
                        .Child(el).DeleteAsync();

                        await task;
                    }
                    catch
                    {

                    }
                }

            }


            List<string> urlImage = new List<string>();

            if (foodModel.Image != null)
            {
                string dirName = _appEnvironment.WebRootPath + "\\tempImage";

                var dirInfo = new DirectoryInfo($"{dirName}\\");

                if (!Directory.Exists(dirName))
                {
                    Directory.CreateDirectory(dirName);
                }


                foreach (var image in foodModel.Image)
                {

                    using (var fileStream = new FileStream(dirInfo + image.FileName, FileMode.Create))
                    {
                        await image.CopyToAsync(fileStream);
                    }

                    using (var fileStream = new FileStream(dirInfo.FullName + image.FileName, FileMode.Open, FileAccess.Read))
                    {
                        var task = new FirebaseStorage("foodproject-xxxx.appspot.com", new FirebaseStorageOptions
                        {
                            AuthTokenAsyncFactory = () => Task.FromResult(auth.FirebaseToken),
                            ThrowOnCancel = true,
                        })
                            .Child("FoodImage")
                            .Child(foodModel.id)
                            .Child(image.FileName)
                            .PutAsync(fileStream);

                        task.Progress.ProgressChanged += (s, e) => Console.WriteLine($"Progress: {e.Percentage} %");

                        var url = await task;

                        urlImage.Add(url);

                        if (image.FileName == foodModel.previewImage) foodModel.previewImage = url;

                    }

                }

                foreach (var file in dirInfo.GetFiles())
                {
                    file.Delete();
                }
            }

            if (urlList != null)
            {
                urlImage.AddRange(urlList);
            }

            FirestoreDb db = FirestoreDb.Create("foodproject-xxxx");
            DocumentReference docRef = db.Collection("food").Document(foodModel.id);
            Dictionary<string, object> updates = new Dictionary<string, object>
            {
                { "name", foodModel.Name },
                { "description", foodModel.Description },
                { "urlImage", urlImage  },
                { "weight", foodModel.Weight },
                { "price", foodModel.Price },
                { "previewImage", foodModel.previewImage},
                { "category", foodModel.category },
            };
            await docRef.UpdateAsync(updates);

            ModelState.Clear();

            return Redirect("/Home/Items/");

        }
    }
}
