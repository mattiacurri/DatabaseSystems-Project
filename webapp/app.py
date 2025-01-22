from flask import Flask, render_template, request, redirect, url_for
from datetime import datetime
import database
import oracledb

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('base.html')

# Operazione 1: Registrazione Cliente
@app.route('/register_customer', methods=['GET', 'POST'])
def register_customer():
    if request.method == 'POST':
        try:
            conn = database.get_connection()
            cursor = conn.cursor()
            
            vat = request.form['vat']
            phone = request.form['phone']
            email = request.form['email']
            cust_type = request.form['type']
            
            # Always create an AddressTY object (even if empty for individual)
            address_type = conn.gettype('ADDRESSTY')
            address_obj = address_type.newobject()
            address_obj.STREET = None
            address_obj.CIVICNUM = None
            address_obj.CITY = None
            address_obj.PROVINCE = None
            address_obj.REGION = None
            address_obj.STATE = None

            if cust_type == 'individual':
                name = request.form['name']
                surname = request.form['surname']
                dob = datetime.strptime(request.form['dob'], '%Y-%m-%d').date()
                company_name = None
            else:
                name = None
                surname = None
                dob = None
                company_name = request.form['companyName']
                address_obj.STREET = request.form['street']
                address_obj.CIVICNUM = int(request.form['civicNum'])
                address_obj.CITY = request.form['city']
                address_obj.PROVINCE = request.form['province']
                address_obj.REGION = request.form['region']
                address_obj.STATE = request.form['state']

            cursor.callproc('registerCustomer', [
                vat, phone, email, cust_type,
                name, surname, dob,
                company_name, address_obj
            ])
                    
            conn.commit()
            cursor.execute("""
                SELECT CODE 
                FROM BusinessAccountTB b 
                WHERE b.customer.VAT = :vat
            """, [vat])
            result = cursor.fetchone()
            if result:
                return render_template('register_customer.html', business_account=result[0])
            return render_template('register_customer.html')
            
        except oracledb.DatabaseError as e:
            error, = e.args
            return render_template('register_customer.html', error=error.message)
        finally:
            cursor.close()
            conn.close()
    
    return render_template('register_customer.html')

# Operazione 2: Aggiungi Ordine
@app.route('/add_order', methods=['GET', 'POST'])
def add_order():
    if request.method == 'POST':
        try:
            conn = database.get_connection()
            cursor = conn.cursor()
            
            # Recupera i dati del form
            order_id = request.form['order_id']
            placing_date = datetime.strptime(request.form['placing_date'], '%Y-%m-%d').date()
            
            cursor.callproc('addOrder', [
                order_id,
                placing_date,
                request.form['order_mode'],
                request.form['order_type'],
                float(request.form['cost']),
                request.form['business_account']
            ])
            
            conn.commit()
            # Get business accounts before rendering template
            cursor.execute("SELECT CODE FROM BusinessAccountTB")
            business_accounts = [row[0] for row in cursor.fetchall()]
            return render_template('add_order.html', success="Order added successfully!", business_accounts=business_accounts)
            
        except oracledb.DatabaseError as e:
            error, = e.args
            # Get business accounts even when there's an error
            cursor.execute("SELECT CODE FROM BusinessAccountTB")
            business_accounts = [row[0] for row in cursor.fetchall()]
            return render_template('add_order.html', error=error.message, business_accounts=business_accounts)
        finally:
            cursor.close()
            conn.close()
    
    # Handle GET request
    try:
        conn = database.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT CODE FROM BusinessAccountTB")
        business_accounts = [row[0] for row in cursor.fetchall()]
        return render_template('add_order.html', business_accounts=business_accounts)
    except oracledb.DatabaseError as e:
        error, = e.args
        return render_template('add_order.html', error=error.message)
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()
    

# Operazione 3: Assegna Ordine a Team
@app.route('/assign_order', methods=['GET', 'POST'])
def assign_order():
    if request.method == 'POST':
        try:
            conn = database.get_connection()
            cursor = conn.cursor()
            cursor.callproc('assignOrderToTeam', [
                request.form['order_id'],
                request.form['team_id']
            ])
            conn.commit()
            # Get lists for dropdowns
            cursor.execute("SELECT ID FROM OrderTB WHERE team IS NULL")
            orders = [row[0] for row in cursor.fetchall()]
            cursor.execute("SELECT ID FROM TeamTB")
            teams = [row[0] for row in cursor.fetchall()]
            return render_template('assign_order.html', orders=orders, teams=teams, success="Order assigned successfully!")
        except oracledb.DatabaseError as e:
            error, = e.args
            # Get lists for dropdowns even when there's an error
            cursor.execute("SELECT ID FROM OrderTB WHERE team IS NULL")
            orders = [row[0] for row in cursor.fetchall()]
            cursor.execute("SELECT ID FROM TeamTB")
            teams = [row[0] for row in cursor.fetchall()]
            return render_template('assign_order.html', error=error.message, orders=orders, teams=teams)
        finally:
            cursor.close()
            conn.close()

    # Get lists for dropdowns
    try:
        conn = database.get_connection()
        cursor = conn.cursor()
        # Get unassigned orders
        cursor.execute("SELECT ID FROM OrderTB WHERE team IS NULL")
        orders = [row[0] for row in cursor.fetchall()]
        # Get all teams
        cursor.execute("SELECT ID FROM TeamTB")
        teams = [row[0] for row in cursor.fetchall()]
        return render_template('assign_order.html', orders=orders, teams=teams)
    except oracledb.DatabaseError as e:
        error, = e.args
        return render_template('assign_order.html', error=error.message)
    finally:
        cursor.close()
        conn.close()

# Operazione 4: Statistiche Team
@app.route('/team_stats', methods=['GET', 'POST'])
def team_stats():
    if request.method == 'POST':
        team_id = request.form['team_id']
        try:
            conn = database.get_connection()
            cursor = conn.cursor()
            
            # Get total orders
            cursor.execute("SELECT totalNumOrder(:1) FROM DUAL", [team_id])
            total_orders = cursor.fetchone()[0]
            
            # Get total cost
            cursor.execute("SELECT totalOrderCost(:1) FROM DUAL", [team_id])
            total_cost = cursor.fetchone()[0]
            
            # Get teams for dropdown
            cursor.execute("SELECT ID FROM TeamTB")
            teams = [row[0] for row in cursor.fetchall()]
            
            return render_template('team_stats.html', 
                                 total_orders=total_orders,
                                 total_cost=total_cost,
                                 team_id=team_id,
                                 teams=teams)
        except oracledb.DatabaseError as e:
            error, = e.args
            return render_template('team_stats.html', error=error.message)
        finally:
            cursor.close()
            conn.close()
    
    # For GET request, just get teams for dropdown
    try:
        conn = database.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT ID FROM TeamTB")
        teams = [row[0] for row in cursor.fetchall()]
        return render_template('team_stats.html', teams=teams)
    except oracledb.DatabaseError as e:
        error, = e.args
        return render_template('team_stats.html', error=error.message)
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

# Operazione 5: Lista Team ordinati
@app.route('/teams_list', methods=['GET', 'POST'])
def teams_list():
    # Default number of rows to display
    rows_to_display = 10
    # Get the current offset from query parameters, default to 0
    offset = int(request.args.get('offset', 0))
    
    if offset < 0:
        offset = 0
    
    if request.method == 'POST':
        # Get number of rows from form input
        rows_to_display = int(request.form.get('num_rows', 20))
        # Reset offset when form is submitted
        offset = 0

    try:
        conn = database.get_connection()
        cursor = conn.cursor()
        
        # Get total count of teams
        cursor.execute("SELECT COUNT(*) FROM TeamTB")
        total_teams = cursor.fetchone()[0]
        
        # Modified query to include OFFSET
        cursor.execute("""
            SELECT ID, performanceScore 
            FROM TeamTB 
            ORDER BY performanceScore DESC
            OFFSET :1 ROWS FETCH NEXT :2 ROWS ONLY
        """, [offset, rows_to_display])
        teams = cursor.fetchall()
        
        # Check if there are more teams to show
        has_next = (offset + rows_to_display) < total_teams
        
        return render_template('teams_list.html',
                               teams=teams,
                               num_rows=rows_to_display,
                               offset=offset,
                               has_next=has_next)
    except oracledb.DatabaseError as e:
        error, = e.args
        return render_template('teams_list.html', error=error.message)
    finally:
        cursor.close()
        conn.close()

@app.route('/success')
def success():
    return render_template('success.html')

if __name__ == '__main__':
    app.run(debug=True)