# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Nettoyer la base de données
Loan.destroy_all
Book.destroy_all
User.destroy_all

# Créer des livres
books = [
  { title: 'Les Misérables', author: 'Victor Hugo', description: 'Roman historique et social français', isbn: '9781234567897', published_year: 1862, category: 'Roman', available: true },
  { title: 'Le Petit Prince', author: 'Antoine de Saint-Exupéry', description: 'Conte poétique et philosophique', isbn: '9782345678901', published_year: 1943, category: 'Conte', available: true },
  { title: '1984', author: 'George Orwell', description: 'Roman dystopique', isbn: '9783456789012', published_year: 1949, category: 'Science-Fiction', available: true },
  { title: 'Guerre et Paix', author: 'Léon Tolstoï', description: 'Épopée historique', isbn: '9784567890123', published_year: 1869, category: 'Roman', available: true },
  { title: 'L\'Étranger', author: 'Albert Camus', description: 'Roman philosophique', isbn: '9785678901234', published_year: 1942, category: 'Roman', available: true }
]

created_books = books.map { |book| Book.create!(book) }

# Créer des utilisateurs (avec firstname et lastname au lieu de name)
users = [
  { firstname: 'Jean', lastname: 'Dupont', email: 'jean@exemple.fr', phone: '0123456789' },
  { firstname: 'Marie', lastname: 'Martin', email: 'marie@exemple.fr', phone: '0987654321' },
  { firstname: 'Pierre', lastname: 'Durand', email: 'pierre@exemple.fr', phone: '0654321987' }
]

created_users = users.map { |user| User.create!(user) }

# Créer des emprunts
loans = [
  { book: created_books[0], user: created_users[0], borrowed_on: Date.today - 10.days, due_date: Date.today + 4.days, status: 'emprunté' },
  { book: created_books[1], user: created_users[1], borrowed_on: Date.today - 15.days, due_date: Date.today - 1.day, status: 'emprunté' },
  { book: created_books[2], user: created_users[2], borrowed_on: Date.today - 30.days, due_date: Date.today - 16.days, returned_on: Date.today - 17.days, status: 'retourné' }
]

loans.each do |loan|
  l = Loan.create!(loan)
  # Mettre à jour le statut du livre si le prêt est en cours
  l.book.update(available: false) unless l.returned_on.present?
end

puts "Base de données initialisée avec #{Book.count} livres, #{User.count} utilisateurs et #{Loan.count} emprunts."