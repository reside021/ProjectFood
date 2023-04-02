using System.ComponentModel.DataAnnotations;

namespace ProjectFood.Models
{
    public class Category
    {
        public List<Dictionary<string, object>> Categories { get; set;} = new List<Dictionary<string, object>>();

        [Required(ErrorMessage = "Введите название блюда")]
        public string newCategory { get; set; }
    }
}
