using Firebase.Auth;
using Firebase.Storage;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.DataProtection.KeyManagement;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using ProjectFood.Helper;
using ProjectFood.Models;
using System;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Runtime;
using System.Text;
using System.Xml.Schema;
using static Google.Rpc.Context.AttributeContext.Types;
using static System.Net.Mime.MediaTypeNames;

namespace ProjectFood.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private IWebHostEnvironment _appEnvironment;
        private HttpClient _httpClient;

        public HomeController(ILogger<HomeController> logger, IWebHostEnvironment appEnvironment)
        {
            _logger = logger;
            _appEnvironment = appEnvironment;
            _httpClient = new HttpClient();
        }

        public IActionResult Index()
        {
            return View();
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

        [HttpGet]
        public async Task<IActionResult> Category()
        {
            Category categoryModel = new Category();

            categoryModel.Categories = await GetCategories();
            return View(categoryModel);
        }


        [HttpPost]
        public async Task<IActionResult> Category(Category category)
        {

            if (!string.IsNullOrWhiteSpace(category.newCategory))
            {
                var id = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();

                FirestoreDb db = FirestoreDb.Create("foodproject-xxxx");
                DocumentReference docRef = db.Collection("category").Document(id);
                Dictionary<string, object> newDoc = new Dictionary<string, object>
                {
                    { "id", id },
                    { "category", category.newCategory },
                };
                await docRef.SetAsync(newDoc);
                return Redirect("Category");
            }
            
            category.Categories = await GetCategories();
            return View(category);
        }



        public async Task<IActionResult> Items()
        {
            FirestoreDb db = FirestoreDb.Create("foodproject-xxxx");
            CollectionReference usersRef = db.Collection("food");
            QuerySnapshot snapshot = await usersRef.GetSnapshotAsync();

            return View(snapshot);
        }

        [HttpGet]
        public async Task<IActionResult> AddFood()
        {
            FoodModel foodModel = new FoodModel();
            foodModel.Categories = await GetCategoriesItems();

            return View(foodModel);
        }

        private async Task<List<SelectListItem>> GetCategoriesItems()
        {
            var categories = await GetCategories();

            List<SelectListItem> listItems = categories.Select(pair => new SelectListItem
            {
                Text = pair["category"].ToString(),
                Value = pair["id"].ToString()
            }).ToList();

            return listItems;
        }

        [HttpPost]
        public async Task<IActionResult> AddFood(FoodModel foodModel)
        {
            var authProvider = new FirebaseAuthProvider(new FirebaseConfig("config"));
            var auth = await authProvider.SignInWithEmailAndPasswordAsync("email", "pass");

            if (ModelState.IsValid)
            {
                var id = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();

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
                               .Child(id)
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
                FirestoreDb db = FirestoreDb.Create("foodproject-xxxx");
                DocumentReference docRef = db.Collection("food").Document(id);
                Dictionary<string, object> newDoc = new Dictionary<string, object>
                {
                    { "id", id },
                    { "name", foodModel.Name },
                    { "description", foodModel.Description },
                    { "urlImage", urlImage  },
                    { "weight", foodModel.Weight },
                    { "price", foodModel.Price },
                    { "previewImage", foodModel.previewImage},
                    { "category", foodModel.category }
                };
                await docRef.SetAsync(newDoc);

                ModelState.Clear();
                return Redirect("AddFood");
            }
            foodModel.Categories = await GetCategoriesItems();

            return View(foodModel);
        }


        [HttpGet]
        public async Task<IActionResult> UsersAsync()
        {

            FirestoreDb db = FirestoreDb.Create("foodproject-xxxx");
            CollectionReference usersRef = db.Collection("users");
            QuerySnapshot snapshot = await usersRef.GetSnapshotAsync();
            return View(snapshot);
        }

        [HttpGet]
        public async Task<IActionResult> Orders()
        {
            return View();
        }

        public async Task<IActionResult> DeleteFood(string id)
        {

            if (id == null) return Redirect("/Home/Items/");

            FirestoreDb db = FirestoreDb.Create("foodproject-xxxx");
            DocumentReference docRef = db.Collection("food").Document(id);
            DocumentSnapshot snapshot = await docRef.GetSnapshotAsync();

            if (!snapshot.Exists)
            {
                return Redirect("/Home/Items/");
            }

            Dictionary<string, object> food = snapshot.ToDictionary();


            var urlList = (food["urlImage"] as List<object>).Cast<string>().ToList();

            List<string> nameImgList = new List<string>();

            if (urlList.Count != 0)
            {
                foreach (var url in urlList)
                {
                    string decodeUrlString = DecodeUrlString(url);

                    int indexSlash = decodeUrlString.LastIndexOf('/');
                    int indexQuestion = decodeUrlString.IndexOf("?");
                    int endLength = decodeUrlString.Substring(indexSlash).Length - decodeUrlString.Substring(indexQuestion).Length;
                    string nameImg = decodeUrlString.Substring(indexSlash + 1, endLength - 1);
                    nameImgList.Add(nameImg);
                }

                var authProvider = new FirebaseAuthProvider(new FirebaseConfig("config"));
                var auth = await authProvider.SignInWithEmailAndPasswordAsync("email", "pass");

                foreach (var el in nameImgList)
                {
                    try
                    {
                        var task = new FirebaseStorage("foodproject-xxxx.appspot.com", new FirebaseStorageOptions
                        {
                            AuthTokenAsyncFactory = () => Task.FromResult(auth.FirebaseToken),
                            ThrowOnCancel = true,
                        })
                        .Child("FoodImage")
                        .Child(id)
                        .Child(el).DeleteAsync();

                        await task;
                    }
                    catch
                    {

                    }
                }
            }

            await docRef.DeleteAsync();

            return RedirectToAction("Items");
        }

        private static string DecodeUrlString(string url)
        {
            string newUrl;
            while ((newUrl = Uri.UnescapeDataString(url)) != url)
                url = newUrl;
            return newUrl;
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}