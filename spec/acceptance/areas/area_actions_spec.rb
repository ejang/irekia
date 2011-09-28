#encoding: UTF-8

require 'spec_helper'

feature "Area's actions page" do

  background do
    @area = get_area_data
  end

  scenario "shows a summary of that area's politicians, actions and generated contents" do
    visit actions_area_path(@area)

    within '.summary' do
      page.should have_css 'h1', :text => 'Educación, Universidades e Investigación'
      page.should have_css 'a.add_to_favorites'
      page.should have_css 'h3', :text => 'Qué hacemos'
      page.should have_css 'p',  :text => String.lorem

      within 'ul.people' do
        page.should have_css 'li a',    :text => 'Virginia Uriarte Rodríguez'
        page.should have_css 'li span', :text => 'Consejera'
        page.should have_css 'li a',    :text => 'Alberto de Zárate López'
        page.should have_css 'li span', :text => 'Vice-consejero'
      end

      #within '.status' do
      #  page.should have_css 'ul li.area span',      :text => '148 acciones esta semana'
      #  page.should have_css 'ul li.area a',         :text => 'Sigue a este área'
      #  page.should have_css 'ul li.questions span', :text => '1 pregunta contestada'
      #  page.should have_css 'ul li.questions a',    :text => 'Haz una pregunta'
      #  page.should have_css 'ul li.proposals span', :text => '1 propuesta abierta'
      #  page.should have_css 'ul li.proposals a',    :text => 'Lanza tu propuesta'
      #end
    end
  end

  scenario 'shows a navigation menu with "actions" selected' do
    visit actions_area_path(@area)

    within '.menu' do
      page.should have_link 'Resumen'
      page.should have_link 'Acciones', :class => 'selected'
      page.should have_link 'Preguntas'
      page.should have_link 'Propuestas'
      page.should have_link 'Agenda'
      page.should have_link 'Equipo'
    end
  end

  scenario 'shows a list of last actions related to that area' do

    visit actions_area_path(@area)

    within '.actions' do
      page.should have_css 'h2', :text => 'Últimas acciones'

      page.should have_css 'a.filter.recent', :text => 'Más recientes'
      page.should have_css 'a.filter.polemic', :text => 'Más polémicas'

      within '.argument' do
        page.should have_css 'p', :text => 'A favor de la propuesta "Actualizar la información publicada sobre las ayudas a familias numerosas"'

        page.should have_css 'img'
        page.should have_css '.footer span.published_at', :text => 'Aritz Aranburu participó hace menos de 1 minuto'
        page.should have_css '.footer span.published_at a', :text => 'Aritz Aranburu'
        page.should have_css '.footer a.comment-count', :text => 'Ningún comentario'
        page.should have_css '.footer a', :text => 'Compartir'
      end

      within '.answer' do
        page.should have_css 'p', :text => 'Contestando a "Hola Virginia, llevo algún tiempo queriendo saber por qué no se pueden llevar perros, gatos u otros animales domésticos a los actos públicos."'
        page.should have_css 'p.excerpt', :text => '"Hola María, en realidad no va a haber ayuda este año. El recorte este"'

        page.should have_css 'img'
        page.should have_css '.footer span.published_at', :text => 'Virginia Uriarte Rodríguez contesto hace menos de 1 minuto'
        page.should have_css '.footer span.published_at a', :text => 'Virginia Uriarte Rodríguez'
        page.should have_css '.footer a', :text => '1 comentario'
        page.should have_css '.footer a', :text => 'Compartir'
      end

      within '.news' do
        page.should have_css 'p', :text => 'Inauguración del nuevo complejo deportivo en la localidad de Getxo'
        page.should have_css 'p.excerpt', :text => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed d...'

        page.should have_css 'img'
        page.should have_css '.footer span.published_at', :text => 'Publicado hace menos de 1 minuto'
        page.should have_css '.footer a', :text => '2 comentarios'
        page.should have_css '.footer a', :text => 'Compartir'
      end

      within '.question' do
        page.should have_css 'p', :text => 'Pregunta para el área...'
        page.should have_css 'p.excerpt', :text => '"Hola Virginia, llevo algún tiempo queriendo saber por qué no se pueden llevar perros, gatos u otros animales domésticos a los actos públicos."'

        page.should have_css 'img'
        page.should have_css '.footer span.published_at', :text => 'María González Pérez hace menos de 1 minuto'
        page.should have_css '.footer span.published_at a', :text => 'María González Pérez'
        page.should have_css '.footer a', :text => 'Ningún comentario'
        page.should have_css '.footer a', :text => 'Compartir'
      end

      within 'ul.selector' do
        page.should have_link 'Todos los tipos'
        page.should have_link 'Noticias'
        page.should have_link 'Actividad de los políticos'
        page.should have_link 'Preguntas'
        page.should have_link 'Propuestas'
        page.should have_link 'Fotos'
        page.should have_link 'Vídeos'
      end

      page.should have_css 'footer .right a', :text => 'ver más acciones'
    end
  end

end
