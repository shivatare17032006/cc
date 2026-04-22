const loginCard = document.querySelector('#loginCard');
const dashboard = document.querySelector('#dashboard');
const loginForm = document.querySelector('#loginForm');
const loginError = document.querySelector('#loginError');
const welcomeText = document.querySelector('#welcomeText');
const logoutBtn = document.querySelector('#logoutBtn');

const statsGrid = document.querySelector('#statsGrid');
const ordersWrap = document.querySelector('#ordersWrap');
const complaintsWrap = document.querySelector('#complaintsWrap');
const usersWrap = document.querySelector('#usersWrap');

const STATUS_OPTIONS = ['Pending', 'Preparing', 'Ready', 'Completed'];

const savedSession = JSON.parse(localStorage.getItem('adminSession') || '{}');
let token = savedSession.token || '';
let apiBase = savedSession.apiBase || 'https://cc-3jx1.onrender.com';
let user = savedSession.user || null;

const apiBaseInput = document.querySelector('#apiBase');
if (apiBaseInput) {
  apiBaseInput.value = apiBase;
}

if (token && user?.role === 'admin') {
  showDashboard();
  loadDashboard();
}

loginForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  loginError.textContent = '';

  const email = document.querySelector('#email').value.trim();
  const password = document.querySelector('#password').value;
  apiBase = (document.querySelector('#apiBase').value || 'https://cc-3jx1.onrender.com').replace(/\/$/, '');

  try {
    const response = await fetch(`${apiBase}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.message || 'Login failed');
    }

    if (data.user?.role !== 'admin') {
      throw new Error('This account is not an admin account');
    }

    token = data.token;
    user = data.user;
    persistSession();
    showDashboard();
    await loadDashboard();
  } catch (error) {
    loginError.textContent = error.message;
  }
});

logoutBtn.addEventListener('click', () => {
  localStorage.removeItem('adminSession');
  token = '';
  user = null;
  loginCard.classList.remove('hidden');
  dashboard.classList.add('hidden');
});

function persistSession() {
  localStorage.setItem(
    'adminSession',
    JSON.stringify({
      token,
      apiBase,
      user,
    })
  );
}

function showDashboard() {
  loginCard.classList.add('hidden');
  dashboard.classList.remove('hidden');
  welcomeText.textContent = `Signed in as ${user?.name || user?.email}`;
}

function authHeaders() {
  return {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
  };
}

async function apiGet(path) {
  const response = await fetch(`${apiBase}${path}`, {
    headers: authHeaders(),
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.message || 'Request failed');
  }
  return data;
}

async function apiPatch(path, payload) {
  const response = await fetch(`${apiBase}${path}`, {
    method: 'PATCH',
    headers: authHeaders(),
    body: JSON.stringify(payload),
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.message || 'Request failed');
  }
  return data;
}

async function loadDashboard() {
  try {
    const [dashboardData, orders, complaints, users] = await Promise.all([
      apiGet('/api/admin/dashboard'),
      apiGet('/api/admin/orders'),
      apiGet('/api/admin/complaints'),
      apiGet('/api/admin/users'),
    ]);

    renderStats(dashboardData.summary, dashboardData.orderStatus);
    renderOrders(orders);
    renderComplaints(complaints);
    renderUsers(users);
  } catch (error) {
    loginError.textContent = error.message;
    dashboard.classList.add('hidden');
    loginCard.classList.remove('hidden');
  }
}

function renderStats(summary, orderStatus) {
  const cards = [
    { label: 'Total Orders', value: summary.totalOrders },
    { label: 'Total Revenue', value: `Rs ${Number(summary.totalRevenue || 0).toFixed(2)}` },
    { label: 'Open Complaints', value: summary.openComplaints },
    { label: 'Total Users', value: summary.totalUsers },
    { label: 'Pending', value: orderStatus.Pending },
    { label: 'Preparing', value: orderStatus.Preparing },
    { label: 'Ready', value: orderStatus.Ready },
    { label: 'Completed', value: orderStatus.Completed },
  ];

  statsGrid.innerHTML = cards
    .map(
      (card) => `
        <div class="stat">
          <div class="label">${card.label}</div>
          <div class="value">${card.value}</div>
        </div>
      `
    )
    .join('');
}

function renderOrders(orders) {
  if (!orders.length) {
    ordersWrap.innerHTML = '<p class="muted">No orders yet.</p>';
    return;
  }

  const rows = orders
    .map((order) => {
      const customer = order.userId?.name || order.userId?.email || 'Unknown';
      const items = (order.items || [])
        .map((item) => `${item.name} x${item.quantity}`)
        .join(', ');

      return `
        <tr>
          <td>${order.orderId || order._id}</td>
          <td>${customer}</td>
          <td>${items}</td>
          <td>Rs ${Number(order.totalAmount || 0).toFixed(2)}</td>
          <td><span class="badge ${order.status}">${order.status}</span></td>
          <td>
            <select data-order-id="${order._id}" class="status-select">
              ${STATUS_OPTIONS.map((status) => `<option ${status === order.status ? 'selected' : ''} value="${status}">${status}</option>`).join('')}
            </select>
          </td>
        </tr>
      `;
    })
    .join('');

  ordersWrap.innerHTML = `
    <table>
      <thead>
        <tr>
          <th>Order ID</th>
          <th>Customer</th>
          <th>Items</th>
          <th>Total</th>
          <th>Status</th>
          <th>Update</th>
        </tr>
      </thead>
      <tbody>${rows}</tbody>
    </table>
  `;

  ordersWrap.querySelectorAll('.status-select').forEach((select) => {
    select.addEventListener('change', async (event) => {
      const orderId = event.target.dataset.orderId;
      const status = event.target.value;
      try {
        await apiPatch(`/api/admin/orders/${orderId}/status`, { status });
        await loadDashboard();
      } catch (error) {
        alert(error.message);
      }
    });
  });
}

function renderComplaints(complaints) {
  if (!complaints.length) {
    complaintsWrap.innerHTML = '<p class="muted">No complaints found.</p>';
    return;
  }

  const rows = complaints
    .map((complaint) => {
      const customer = complaint.isAnonymous
        ? 'Anonymous'
        : complaint.userId?.name || complaint.userId?.email || 'Unknown';

      const resolveButton =
        complaint.status === 'Resolved'
          ? '<span class="badge Resolved">Resolved</span>'
          : `<button data-complaint-id="${complaint._id}" class="resolve-btn">Resolve</button>`;

      return `
        <tr>
          <td>${complaint.complaintId || complaint._id}</td>
          <td>${customer}</td>
          <td>${complaint.type}</td>
          <td>${complaint.priority}</td>
          <td>${complaint.description}</td>
          <td>${resolveButton}</td>
        </tr>
      `;
    })
    .join('');

  complaintsWrap.innerHTML = `
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>User</th>
          <th>Type</th>
          <th>Priority</th>
          <th>Description</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>${rows}</tbody>
    </table>
  `;

  complaintsWrap.querySelectorAll('.resolve-btn').forEach((button) => {
    button.addEventListener('click', async (event) => {
      const complaintId = event.target.dataset.complaintId;
      try {
        await apiPatch(`/api/admin/complaints/${complaintId}/resolve`, {});
        await loadDashboard();
      } catch (error) {
        alert(error.message);
      }
    });
  });
}

function renderUsers(users) {
  if (!users.length) {
    usersWrap.innerHTML = '<p class="muted">No users found.</p>';
    return;
  }

  const rows = users
    .map(
      (account) => `
        <tr>
          <td>${account.name || '-'}</td>
          <td>${account.email || '-'}</td>
          <td>${account.phone || '-'}</td>
          <td>${account.location || '-'}</td>
          <td>${account.role || 'student'}</td>
          <td>${new Date(account.createdAt).toLocaleString()}</td>
        </tr>
      `
    )
    .join('');

  usersWrap.innerHTML = `
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Email</th>
          <th>Phone</th>
          <th>Location</th>
          <th>Role</th>
          <th>Joined</th>
        </tr>
      </thead>
      <tbody>${rows}</tbody>
    </table>
  `;
}
