using Microsoft.AspNetCore.Mvc.Rendering;
using System.ComponentModel.DataAnnotations;

namespace ProjectFood.Models
{
    public class FoodModel
    {
        [Required(ErrorMessage = "Введите название блюда")]
        [MaxLength(50, ErrorMessage = "Длина не должна превышать больше 50 символов")]
        public string Name { get; set; }

        public string? Description { get; set; }

        public IFormFileCollection? Image { get; set; }

        [Required(ErrorMessage = "Введите вес блюда")]
        [Range(0, int.MaxValue, ErrorMessage = "Введите корректное число")]
        public int? Weight { get; set; }

        [Required(ErrorMessage = "Введите цену блюда")]
        [Range(0, int.MaxValue, ErrorMessage = "Введите корректное число")]
        public int? Price { get; set; }

        public List<string>? urlList { get; set; }

        public string? id { get; set; }

        [Required(ErrorMessage = "Выберите изображение для превью!")]
        public string previewImage { get; set; }

        public List<SelectListItem>? Categories { get; set; }

        [Required(ErrorMessage = "Выберите категорию блюда")]
        public string category { get;set; }
    }
}
